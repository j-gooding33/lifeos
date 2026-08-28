import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/money_format.dart';
import 'package:life_os/data/repositories/models/app_category.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_prompt_dialog.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/finance/application/finance_providers.dart';

/// §22.2: "quick add (amount keypad first, then category, then optional
/// note — amount is the first tap, always)." One screen for both create
/// (`expenseId == null`) and edit, the same pattern `TaskDetailScreen` uses.
class ExpenseEditScreen extends ConsumerWidget {
  const ExpenseEditScreen({this.expenseId, super.key});

  final String? expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final id = expenseId;
    if (id == null) {
      return const _ExpenseEditBody(key: ValueKey('new'), existing: null);
    }
    final asyncExpense = ref.watch(expenseByIdProvider(id));
    return asyncExpense.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const Center(child: Text("Couldn't load this entry."))),
      data: (expense) {
        if (expense == null) {
          return Scaffold(backgroundColor: colors.neutrals.bg, appBar: AppBar(), body: const Center(child: Text('This entry no longer exists.')));
        }
        return _ExpenseEditBody(key: ValueKey(expense.id), existing: expense);
      },
    );
  }
}

class _ExpenseEditBody extends ConsumerStatefulWidget {
  const _ExpenseEditBody({required this.existing, super.key});

  final AppExpense? existing;

  bool get isNew => existing == null;

  @override
  ConsumerState<_ExpenseEditBody> createState() => _ExpenseEditBodyState();
}

class _ExpenseEditBodyState extends ConsumerState<_ExpenseEditBody> {
  late var _digits = widget.existing?.amountMinor.toString() ?? '';
  late var _type = widget.existing?.type ?? ExpenseType.expense;
  late var _categoryId = widget.existing?.categoryId;
  late final _noteController = TextEditingController(text: widget.existing?.note ?? '');
  late final _date = widget.existing?.date ?? CivilDate.fromDateTime(DateTime.now());

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int get _amountMinor => _digits.isEmpty ? 0 : int.parse(_digits);

  void _tapDigit(String digit) {
    if (_digits.length >= 9) return;
    setState(() => _digits = _digits == '0' ? digit : _digits + digit);
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _save(String currency) async {
    final repository = ref.read(financeRepositoryProvider);
    final note = _noteController.text.trim();
    final existing = widget.existing;

    if (existing == null) {
      final userId = await ref.read(currentUserIdProvider.future);
      await repository.createExpense(
        userId: userId,
        type: _type,
        amountMinor: _amountMinor,
        currency: currency,
        date: _date,
        categoryId: _categoryId,
        note: note.isEmpty ? null : note,
      );
    } else {
      await repository.updateExpense(
        existing.copyWith(
          type: _type,
          amountMinor: _amountMinor,
          categoryId: _categoryId,
          clearCategory: _categoryId == null,
          date: _date,
          note: note,
          clearNote: note.isEmpty,
        ),
      );
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this entry?', message: 'This cannot be undone.');
    if (!confirmed) return;
    await ref.read(financeRepositoryProvider).deleteExpense(widget.existing!.id);
    if (mounted) context.pop();
  }

  Future<void> _addCategory() async {
    final name = await LPromptDialog.show(context, title: 'New category', label: 'Name', confirmLabel: 'Create');
    if (name == null || !mounted) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref.read(financeRepositoryProvider).createExpenseCategory(userId: userId, name: name);
    result.when(ok: (category) => setState(() => _categoryId = category.id), err: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = ref.watch(expenseCategoriesProvider).value ?? const <AppCategory>[];
    final currency = ref.watch(currentCurrencyProvider).value ?? 'GBP';

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(widget.isNew ? 'Add expense' : 'Edit expense'),
        actions: [if (!widget.isNew) IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: _delete)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          Center(
            child: Text(formatMoney(_amountMinor, currency), style: context.textStyles.title1.copyWith(color: colors.neutrals.ink)),
          ),
          const SizedBox(height: LifeSpace.s20),
          LSegmented<ExpenseType>(
            segments: const {ExpenseType.expense: 'Expense', ExpenseType.income: 'Income'},
            selected: _type,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: LifeSpace.s20),
          _Keypad(onDigit: _tapDigit, onBackspace: _backspace),
          const SizedBox(height: LifeSpace.s24),
          Wrap(
            spacing: LifeSpace.s8,
            runSpacing: LifeSpace.s8,
            children: [
              for (final category in categories)
                LChip(
                  label: category.name,
                  selected: _categoryId == category.id,
                  onTap: () => setState(() => _categoryId = category.id == _categoryId ? null : category.id),
                ),
              LChip(label: 'New category', icon: Icons.add, onTap: _addCategory),
            ],
          ),
          const SizedBox(height: LifeSpace.s20),
          LTextField(controller: _noteController, label: 'Note (optional)', outlined: true),
          const SizedBox(height: LifeSpace.s24),
          LButton(label: widget.isNew ? 'Add' : 'Save', onPressed: _amountMinor > 0 ? () => _save(currency) : null),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: LifeSpace.s8,
      crossAxisSpacing: LifeSpace.s8,
      childAspectRatio: 1.6,
      children: [
        for (final key in _keys)
          if (key.isEmpty)
            const SizedBox.shrink()
          else
            Material(
              color: colors.neutrals.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: key == '⌫' ? onBackspace : () => onDigit(key),
                child: Center(child: Text(key, style: context.textStyles.title3.copyWith(color: colors.neutrals.ink))),
              ),
            ),
      ],
    );
  }
}
