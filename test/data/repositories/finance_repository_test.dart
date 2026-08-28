import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/finance_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/finance_repository.dart';
import 'package:life_os/data/repositories/models/app_budget.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';

T _ok<T>(Result<T, Failure> result) => result.when(ok: (v) => v, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late FinanceRepository repository;
  const today = CivilDate(2026, 8, 28);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FinanceRepository(FinanceDao(database));
  });

  tearDown(() => database.close());

  test('createExpense then watchExpenses round-trips amount, type, currency and note', () async {
    final expense = _ok(
      await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 1250, currency: 'GBP', date: today, note: 'Coffee'),
    );
    expect(expense.amountMinor, 1250);

    final all = await repository.watchExpenses('u1').first;
    expect(all, hasLength(1));
    expect(all.single.note, 'Coffee');
    expect(all.single.type, ExpenseType.expense);
  });

  test('amountMinor is never a double — 1250 minor units is exactly £12.50, not a rounded float', () async {
    final expense = _ok(await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 999, currency: 'GBP', date: today));
    final reloaded = await repository.watchExpenseById(expense.id).first;
    expect(reloaded!.amountMinor, 999);
  });

  test('updateExpense can change category and clear the note', () async {
    final expense = _ok(
      await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 500, currency: 'GBP', date: today, categoryId: 'c1', note: 'Snack'),
    );
    await repository.updateExpense(expense.copyWith(categoryId: 'c2', note: '', clearNote: true));

    final reloaded = await repository.watchExpenseById(expense.id).first;
    expect(reloaded!.categoryId, 'c2');
    expect(reloaded.note, isNull);
  });

  test('deleteExpense is a soft delete', () async {
    final expense = _ok(await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 500, currency: 'GBP', date: today));
    await repository.deleteExpense(expense.id);
    expect(await repository.watchExpenses('u1').first, isEmpty);
    expect(await repository.watchExpenseById(expense.id).first, isNull);
  });

  test("watchExpenses only returns the given user's expenses, newest date first", () async {
    await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 100, currency: 'GBP', date: today.addDays(-1));
    await repository.createExpense(userId: 'u1', type: ExpenseType.expense, amountMinor: 200, currency: 'GBP', date: today);
    await repository.createExpense(userId: 'u2', type: ExpenseType.expense, amountMinor: 300, currency: 'GBP', date: today);

    final all = await repository.watchExpenses('u1').first;
    expect(all.map((e) => e.amountMinor), [200, 100]);
  });

  test('createBudget then watchBudgets round-trips amount, period and category', () async {
    final budget = _ok(await repository.createBudget(userId: 'u1', amountMinor: 20000, period: BudgetPeriod.monthly, categoryId: 'c1'));
    expect(budget.categoryId, 'c1');

    final all = await repository.watchBudgets('u1').first;
    expect(all.single.amountMinor, 20000);
    expect(all.single.period, BudgetPeriod.monthly);
  });

  test('an overall budget has categoryId == null and updateBudget can clear it back to overall', () async {
    final budget = _ok(await repository.createBudget(userId: 'u1', amountMinor: 10000, period: BudgetPeriod.weekly, categoryId: 'c1'));
    await repository.updateBudget(budget.copyWith(clearCategory: true));

    final reloaded = await repository.watchBudgets('u1').first;
    expect(reloaded.single.categoryId, isNull);
  });

  test('deleteBudget is a soft delete', () async {
    final budget = _ok(await repository.createBudget(userId: 'u1', amountMinor: 10000, period: BudgetPeriod.monthly));
    await repository.deleteBudget(budget.id);
    expect(await repository.watchBudgets('u1').first, isEmpty);
  });

  test('createExpenseCategory then watchExpenseCategories round-trips, scoped to the expense domain', () async {
    final category = _ok(await repository.createExpenseCategory(userId: 'u1', name: 'Groceries', colour: 'ember'));
    expect(category.domain, 'expense');

    final all = await repository.watchExpenseCategories('u1').first;
    expect(all.map((c) => c.name), ['Groceries']);
    expect(all.single.colour, 'ember');
  });
}
