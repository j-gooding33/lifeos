import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/utils/money_format.dart';
import 'package:life_os/data/repositories/models/app_budget.dart';
import 'package:life_os/data/repositories/models/app_category.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/finance/application/finance_providers.dart';

/// §22.2's budgets screen. A budget is either overall (`categoryId ==
/// null`) or scoped to one category; "spent" is always the current
/// calendar month regardless of `period`, since `weekly` budgets are rare
/// enough this pass doesn't build a separate week-window calculation —
/// see DECISIONS.md.
class FinanceBudgetsScreen extends ConsumerWidget {
  const FinanceBudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncBudgets = ref.watch(allBudgetsProvider);
    final categories = ref.watch(expenseCategoriesProvider).value ?? const <AppCategory>[];
    final expenses = ref.watch(allExpensesProvider).value ?? const <AppExpense>[];
    final currency = ref.watch(currentCurrencyProvider).value ?? 'GBP';
    final now = DateTime.now();
    final thisMonthSpend = expenses.where((e) => e.type == ExpenseType.expense && e.date.year == now.year && e.date.month == now.month).toList();

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'New budget', onPressed: () => _editBudget(context, ref, categories: categories)),
        ],
      ),
      body: asyncBudgets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const SizedBox.shrink(),
        data: (budgets) {
          if (budgets.isEmpty) {
            return LEmptyState(
              icon: Icons.pie_chart_outline,
              title: 'No budgets yet',
              message: 'Set a monthly limit, overall or per category, with the + button.',
              actionLabel: 'New budget',
              onAction: () => _editBudget(context, ref, categories: categories),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(LifeSpace.s16),
            itemCount: budgets.length,
            separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s16),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetTile(
                budget: budget,
                categories: categories,
                spend: thisMonthSpend,
                currency: currency,
                onTap: () => _editBudget(context, ref, categories: categories, existing: budget),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editBudget(BuildContext context, WidgetRef ref, {required List<AppCategory> categories, AppBudget? existing}) async {
    final amountController = TextEditingController(text: existing == null ? '' : (existing.amountMinor / 100).toStringAsFixed(2));
    var period = existing?.period ?? BudgetPeriod.monthly;
    var categoryId = existing?.categoryId;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(existing == null ? 'New budget' : 'Edit budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LTextField(controller: amountController, label: 'Amount', outlined: true, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: LifeSpace.s12),
                LSegmented<BudgetPeriod>(
                  segments: const {BudgetPeriod.monthly: 'Monthly', BudgetPeriod.weekly: 'Weekly'},
                  selected: period,
                  onChanged: (value) => setState(() => period = value),
                ),
                const SizedBox(height: LifeSpace.s12),
                DropdownButton<String?>(
                  value: categoryId,
                  hint: const Text('Overall (no category)'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(child: Text('Overall (no category)')),
                    for (final category in categories) DropdownMenuItem(value: category.id, child: Text(category.name)),
                  ],
                  onChanged: (value) => setState(() => categoryId = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true || !context.mounted) return;
    final amountMinor = ((double.tryParse(amountController.text.trim()) ?? 0) * 100).round();
    if (amountMinor <= 0) return;

    final repository = ref.read(financeRepositoryProvider);
    if (existing == null) {
      final userId = await ref.read(currentUserIdProvider.future);
      await repository.createBudget(userId: userId, amountMinor: amountMinor, period: period, categoryId: categoryId);
    } else {
      await repository.updateBudget(existing.copyWith(amountMinor: amountMinor, period: period, categoryId: categoryId, clearCategory: categoryId == null));
    }
  }
}

class _BudgetTile extends ConsumerWidget {
  const _BudgetTile({required this.budget, required this.categories, required this.spend, required this.currency, required this.onTap});

  final AppBudget budget;
  final List<AppCategory> categories;
  final List<AppExpense> spend;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final spent = spend.where((e) => budget.categoryId == null || e.categoryId == budget.categoryId).fold<int>(0, (sum, e) => sum + e.amountMinor);
    var label = 'Overall';
    for (final category in categories) {
      if (category.id == budget.categoryId) label = category.name;
    }
    final over = spent > budget.amountMinor;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _confirmDelete(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink))),
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
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this budget?', message: 'This cannot be undone.');
    if (confirmed) {
      await ref.read(financeRepositoryProvider).deleteBudget(budget.id);
    }
  }
}
