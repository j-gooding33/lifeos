import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/budgets_table.dart';
import 'package:life_os/data/local/tables/categories_table.dart';
import 'package:life_os/data/local/tables/expenses_table.dart';

part 'finance_dao.g.dart';

@DriftAccessor(tables: [Expenses, Budgets, Categories])
class FinanceDao extends DatabaseAccessor<AppDatabase> with _$FinanceDaoMixin {
  FinanceDao(super.db);

  Stream<List<Expense>> watchExpenses(String userId) {
    final query = select(expenses)
      ..where((e) => e.userId.equals(userId) & e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm.desc(e.date)]);
    return query.watch();
  }

  Stream<Expense?> watchExpenseById(String id) {
    final query = select(expenses)..where((e) => e.id.equals(id) & e.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<void> upsertExpense(ExpensesCompanion entry) => into(expenses).insertOnConflictUpdate(entry);

  Future<void> softDeleteExpense(String id, int now) =>
      (update(expenses)..where((e) => e.id.equals(id))).write(ExpensesCompanion(deletedAt: Value(now)));

  Stream<List<Budget>> watchBudgets(String userId) {
    final query = select(budgets)..where((b) => b.userId.equals(userId) & b.deletedAt.isNull());
    return query.watch();
  }

  Future<void> upsertBudget(BudgetsCompanion entry) => into(budgets).insertOnConflictUpdate(entry);

  Future<void> softDeleteBudget(String id, int now) =>
      (update(budgets)..where((b) => b.id.equals(id))).write(BudgetsCompanion(deletedAt: Value(now)));

  Stream<List<Category>> watchCategories(String userId, String domain) {
    final query = select(categories)
      ..where((c) => c.userId.equals(userId) & c.domain.equals(domain) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.sortIndex)]);
    return query.watch();
  }

  Future<void> upsertCategory(CategoriesCompanion entry) => into(categories).insertOnConflictUpdate(entry);
}
