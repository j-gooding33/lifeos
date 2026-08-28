import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/money_format.dart';
import 'package:life_os/data/repositories/models/app_budget.dart';
import 'package:life_os/data/repositories/models/app_category.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/finance/application/finance_providers.dart';
import 'package:life_os/features/finance/presentation/widgets/category_donut.dart';
import 'package:life_os/routing/routes.dart';

/// §22.2: "Deliberately light... Nothing predictive, nothing advisory."
/// Month spend, budget bars, a category donut, recent transactions — no
/// forecasting, no financial advice anywhere on this screen.
class FinanceOverviewScreen extends ConsumerWidget {
  const FinanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncExpenses = ref.watch(allExpensesProvider);
    final asyncBudgets = ref.watch(allBudgetsProvider);
    final asyncCategories = ref.watch(expenseCategoriesProvider);
    final currency = ref.watch(currentCurrencyProvider).value ?? 'GBP';

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          IconButton(icon: const Icon(Icons.pie_chart_outline), tooltip: 'Budgets', onPressed: () => context.push(Routes.financeBudgets)),
          IconButton(icon: const Icon(Icons.add), tooltip: 'Add expense', onPressed: () => context.push(Routes.financeExpense.replaceFirst(':id', 'new'))),
        ],
      ),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your finances.", onRetry: () => ref.invalidate(allExpensesProvider)),
        data: (expenses) {
          if (expenses.isEmpty) {
            return LEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No expenses yet',
              message: 'Log spending or income with the + button — manual entry only, no bank connection.',
              actionLabel: 'Add expense',
              onAction: () => context.push(Routes.financeExpense.replaceFirst(':id', 'new')),
            );
          }
          final today = CivilDate.fromDateTime(DateTime.now());
          final thisMonth = expenses.where((e) => e.date.year == today.year && e.date.month == today.month).toList();
          final monthSpend = thisMonth.where((e) => e.type == ExpenseType.expense).fold<int>(0, (sum, e) => sum + e.amountMinor);
          final monthIncome = thisMonth.where((e) => e.type == ExpenseType.income).fold<int>(0, (sum, e) => sum + e.amountMinor);
          final categories = asyncCategories.value ?? const <AppCategory>[];
          final budgets = asyncBudgets.value ?? const <AppBudget>[];

          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s20),
            children: [
              LCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THIS MONTH', style: context.textStyles.micro.copyWith(color: colors.neutrals.ink3)),
                    const SizedBox(height: LifeSpace.s4),
                    Text(formatMoney(monthSpend, currency), style: context.textStyles.title1.copyWith(color: colors.neutrals.ink)),
                    if (monthIncome > 0) ...[
                      const SizedBox(height: LifeSpace.s4),
                      Text('+${formatMoney(monthIncome, currency)} income', style: context.textStyles.caption.copyWith(color: colors.semantic('success').base)),
                    ],
                  ],
                ),
              ),
              if (budgets.isNotEmpty) ...[
                const SizedBox(height: LifeSpace.cardGap),
                LCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LSectionHeader(title: 'Budgets'),
                      const SizedBox(height: LifeSpace.s12),
                      for (final budget in budgets) _BudgetRow(budget: budget, categories: categories, thisMonth: thisMonth, currency: currency),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: LifeSpace.cardGap),
              LCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LSectionHeader(title: 'By category'),
                    const SizedBox(height: LifeSpace.s12),
                    CategoryDonut(
                      currency: currency,
                      slices: _categorySlices(thisMonth, categories),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LifeSpace.cardGap),
              const LSectionHeader(title: 'Recent'),
              const SizedBox(height: LifeSpace.s8),
              for (final expense in expenses.take(15)) _ExpenseRow(expense: expense, categories: categories, currency: currency),
            ],
          );
        },
      ),
    );
  }

  List<CategorySlice> _categorySlices(List<AppExpense> monthExpenses, List<AppCategory> categories) {
    final totals = <String?, int>{};
    for (final expense in monthExpenses.where((e) => e.type == ExpenseType.expense)) {
      totals[expense.categoryId] = (totals[expense.categoryId] ?? 0) + expense.amountMinor;
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in entries)
        CategorySlice(
          label: entry.key == null ? 'Uncategorised' : (_categoryName(categories, entry.key) ?? 'Uncategorised'),
          amountMinor: entry.value,
        ),
    ];
  }
}

String? _categoryName(List<AppCategory> categories, String? categoryId) {
  for (final category in categories) {
    if (category.id == categoryId) return category.name;
  }
  return null;
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.budget, required this.categories, required this.thisMonth, required this.currency});

  final AppBudget budget;
  final List<AppCategory> categories;
  final List<AppExpense> thisMonth;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spent = thisMonth
        .where((e) => e.type == ExpenseType.expense && (budget.categoryId == null || e.categoryId == budget.categoryId))
        .fold<int>(0, (sum, e) => sum + e.amountMinor);
    final label = budget.categoryId == null ? 'Overall' : (_categoryName(categories, budget.categoryId) ?? 'Overall');
    final over = spent > budget.amountMinor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: context.textStyles.body.copyWith(color: colors.neutrals.ink))),
              Text(
                '${formatMoney(spent, currency)} / ${formatMoney(budget.amountMinor, currency)}',
                style: context.textStyles.caption.copyWith(color: over ? colors.semantic('danger').base : colors.neutrals.ink2),
              ),
            ],
          ),
          const SizedBox(height: LifeSpace.s4),
          LProgressBar(value: budget.amountMinor == 0 ? 0 : spent / budget.amountMinor, semanticLabel: '$label budget'),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense, required this.categories, required this.currency});

  final AppExpense expense;
  final List<AppCategory> categories;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoryName = expense.categoryId == null ? null : _categoryName(categories, expense.categoryId);
    final isIncome = expense.type == ExpenseType.income;
    final amountText = '${isIncome ? '+' : '-'}${formatMoney(expense.amountMinor, currency)}';

    return LListTile(
      leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? colors.semantic('success').base : colors.neutrals.ink2),
      title: expense.note?.isNotEmpty ?? false ? expense.note! : (categoryName ?? (isIncome ? 'Income' : 'Expense')),
      subtitle: expense.date.toIso(),
      trailing: Text(
        amountText,
        style: context.textStyles.bodyStrong.copyWith(color: isIncome ? colors.semantic('success').base : colors.neutrals.ink),
      ),
      onTap: () => context.push(Routes.financeExpense.replaceFirst(':id', expense.id)),
    );
  }
}
