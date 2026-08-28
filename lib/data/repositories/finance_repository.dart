import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/finance_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_budget.dart';
import 'package:life_os/data/repositories/models/app_category.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:uuid/uuid.dart';

const _expenseCategoryDomain = 'expense';

/// §22.2. "Deliberately light. Manual entry only" — no bank connection, no
/// predictive/advisory statistics (§22.2's own words).
class FinanceRepository {
  FinanceRepository(this._dao);

  final FinanceDao _dao;

  Stream<List<AppExpense>> watchExpenses(String userId) => _dao.watchExpenses(userId).map((rows) => rows.map(_expenseToDomain).toList());

  Stream<AppExpense?> watchExpenseById(String id) => _dao.watchExpenseById(id).map((row) => row == null ? null : _expenseToDomain(row));

  Future<Result<AppExpense, Failure>> createExpense({
    required String userId,
    required ExpenseType type,
    required int amountMinor,
    required String currency,
    required CivilDate date,
    String? categoryId,
    String? note,
  }) async {
    try {
      final expense = AppExpense(
        id: const Uuid().v4(),
        userId: userId,
        type: type,
        amountMinor: amountMinor,
        currency: currency,
        date: date,
        categoryId: categoryId,
        note: note,
      );
      await _saveExpense(expense);
      return Ok(expense);
    } on Object catch (e) {
      return Err(DatabaseFailure('createExpense failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateExpense(AppExpense expense) async {
    try {
      await _saveExpense(expense);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateExpense failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteExpense(String id) async {
    try {
      await _dao.softDeleteExpense(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteExpense failed: $e'));
    }
  }

  Future<void> _saveExpense(AppExpense expense) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsertExpense(
      db.ExpensesCompanion(
        id: Value(expense.id),
        userId: Value(expense.userId),
        type: Value(expense.type.name),
        amountMinor: Value(expense.amountMinor),
        currency: Value(expense.currency),
        categoryId: Value(expense.categoryId),
        date: Value(expense.date.toIso()),
        note: Value(expense.note),
        recurrenceRule: Value(expense.recurrenceRule),
        createdAt: Value(expense.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  AppExpense _expenseToDomain(db.Expense row) {
    return AppExpense(
      id: row.id,
      userId: row.userId,
      type: ExpenseType.values.firstWhere((t) => t.name == row.type, orElse: () => ExpenseType.expense),
      amountMinor: row.amountMinor,
      currency: row.currency,
      categoryId: row.categoryId,
      date: CivilDate.parse(row.date),
      note: row.note,
      recurrenceRule: row.recurrenceRule,
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      updatedAt: row.updatedAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.updatedAt!),
    );
  }

  Stream<List<AppBudget>> watchBudgets(String userId) => _dao.watchBudgets(userId).map((rows) => rows.map(_budgetToDomain).toList());

  Future<Result<AppBudget, Failure>> createBudget({
    required String userId,
    required int amountMinor,
    required BudgetPeriod period,
    String? categoryId,
  }) async {
    try {
      final budget = AppBudget(id: const Uuid().v4(), userId: userId, amountMinor: amountMinor, period: period, categoryId: categoryId);
      await _saveBudget(budget);
      return Ok(budget);
    } on Object catch (e) {
      return Err(DatabaseFailure('createBudget failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateBudget(AppBudget budget) async {
    try {
      await _saveBudget(budget);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateBudget failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteBudget(String id) async {
    try {
      await _dao.softDeleteBudget(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteBudget failed: $e'));
    }
  }

  Future<void> _saveBudget(AppBudget budget) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsertBudget(
      db.BudgetsCompanion(
        id: Value(budget.id),
        userId: Value(budget.userId),
        categoryId: Value(budget.categoryId),
        amountMinor: Value(budget.amountMinor),
        period: Value(budget.period.name),
        startDate: Value(budget.startDate?.toIso()),
        updatedAt: Value(now),
      ),
    );
  }

  AppBudget _budgetToDomain(db.Budget row) {
    return AppBudget(
      id: row.id,
      userId: row.userId,
      categoryId: row.categoryId,
      amountMinor: row.amountMinor,
      period: BudgetPeriod.values.firstWhere((p) => p.name == row.period, orElse: () => BudgetPeriod.monthly),
      startDate: row.startDate == null ? null : CivilDate.parse(row.startDate!),
    );
  }

  Stream<List<AppCategory>> watchExpenseCategories(String userId) =>
      _dao.watchCategories(userId, _expenseCategoryDomain).map((rows) => rows.map(_categoryToDomain).toList());

  Future<Result<AppCategory, Failure>> createExpenseCategory({required String userId, required String name, String? colour}) async {
    try {
      final category = AppCategory(id: const Uuid().v4(), userId: userId, domain: _expenseCategoryDomain, name: name, colour: colour);
      await _dao.upsertCategory(
        db.CategoriesCompanion(
          id: Value(category.id),
          userId: Value(category.userId),
          domain: Value(category.domain),
          name: Value(category.name),
          colour: Value(category.colour),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      return Ok(category);
    } on Object catch (e) {
      return Err(DatabaseFailure('createExpenseCategory failed: $e'));
    }
  }

  AppCategory _categoryToDomain(db.Category row) {
    return AppCategory(id: row.id, userId: row.userId, domain: row.domain, name: row.name, colour: row.colour, icon: row.icon, sortIndex: row.sortIndex);
  }
}
