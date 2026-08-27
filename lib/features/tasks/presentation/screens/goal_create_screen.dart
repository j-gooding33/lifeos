import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/goal_providers.dart';
import 'package:life_os/features/tasks/presentation/goal_colour.dart';

const _typeLabels = {
  GoalType.count: 'Count',
  GoalType.quantity: 'Quantity',
  GoalType.duration: 'Duration',
  GoalType.currency: 'Money',
  GoalType.milestone: 'Milestones',
  GoalType.boolean: 'Yes / No',
};

const _colourOptions = ['goals', 'plans', 'habits', 'tasks', 'study'];

/// §12.2's field list, minus `milestones[]`/`linkedPlanIds[]`/
/// `linkedProjectIds[]` — milestones are added from the detail screen once
/// the goal exists, and linked plans/projects come from *their* `goalId`
/// pointing here, never the other way round (no array columns needed).
class GoalCreateScreen extends ConsumerStatefulWidget {
  const GoalCreateScreen({super.key});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  var _type = GoalType.count;
  var _colour = 'goals';
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _needsTarget => _type != GoalType.milestone && _type != GoalType.boolean;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final target = _needsTarget ? double.tryParse(_targetController.text.trim()) : null;
    await ref.read(goalRepositoryProvider).createGoal(
      userId: userId,
      title: title,
      type: _type,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      targetValue: target,
      unit: _needsTarget && _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : null,
      startDate: _startDate == null ? null : CivilDate.fromDateTime(_startDate!),
      endDate: _endDate == null ? null : CivilDate.fromDateTime(_endDate!),
      colour: _colour,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('New goal')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LifeSpace.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LTextField(controller: _titleController, label: 'Title', outlined: true, autofocus: true),
                    const SizedBox(height: LifeSpace.s12),
                    LTextField(controller: _descriptionController, label: 'Description (optional)', outlined: true),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Type'),
                    Wrap(
                      spacing: LifeSpace.s8,
                      runSpacing: LifeSpace.s8,
                      children: [
                        for (final type in GoalType.values)
                          LChip(label: _typeLabels[type]!, selected: _type == type, onTap: () => setState(() => _type = type)),
                      ],
                    ),
                    if (_needsTarget) ...[
                      const SizedBox(height: LifeSpace.s20),
                      _label(context, 'Target'),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: LTextField(controller: _targetController, placeholder: '20', keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: LifeSpace.s12),
                          Expanded(child: LTextField(controller: _unitController, placeholder: 'books')),
                        ],
                      ),
                    ],
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Starts (optional)'),
                    LDatePicker(date: _startDate, onChanged: (d) => setState(() => _startDate = d)),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Ends (optional)'),
                    LDatePicker(date: _endDate, onChanged: (d) => setState(() => _endDate = d)),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Colour'),
                    Wrap(
                      spacing: LifeSpace.s8,
                      children: [for (final domain in _colourOptions) _colourSwatch(context, domain)],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LifeSpace.s20),
              child: LButton(label: 'Create', onPressed: _titleController.text.trim().isEmpty ? null : _save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: LifeSpace.s8),
      child: Text(text, style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
    );
  }

  Widget _colourSwatch(BuildContext context, String domainName) {
    final colour = resolveGoalColour(context, domainName);
    final selected = _colour == domainName;
    return GestureDetector(
      onTap: () => setState(() => _colour = domainName),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colour.base,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: context.colors.neutrals.ink, width: 2) : null,
        ),
      ),
    );
  }
}
