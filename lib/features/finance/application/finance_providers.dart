import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/finance_dao.dart';
import 'package:life_os/data/repositories/finance_repository.dart';
import 'package:life_os/data/repositories/models/app_budget.dart';
import 'package:life_os/data/repositories/models/app_category.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finance_providers.g.dart';

@Riverpod(keepAlive: true)
FinanceRepository financeRepository(Ref ref) {
  return FinanceRepository(FinanceDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppExpense>> allExpenses(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(financeRepositoryProvider).watchExpenses(userId);
}

@riverpod
Stream<AppExpense?> expenseById(Ref ref, String expenseId) {
  return ref.watch(financeRepositoryProvider).watchExpenseById(expenseId);
}

/// §22.2's single onboarding-chosen currency (`AppProfile.currency`,
/// default `'GBP'`) — Finance reads it rather than storing its own copy.
@riverpod
Stream<String> currentCurrency(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(profileRepositoryProvider).watchProfile(userId).map((p) => p?.currency ?? 'GBP');
}

@riverpod
Stream<List<AppBudget>> allBudgets(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(financeRepositoryProvider).watchBudgets(userId);
}

@riverpod
Stream<List<AppCategory>> expenseCategories(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(financeRepositoryProvider).watchExpenseCategories(userId);
}
