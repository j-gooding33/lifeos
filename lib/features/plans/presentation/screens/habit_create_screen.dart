import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/widgets/rhythm_editor.dart';

const _colourOptions = ['habits', 'plans', 'films', 'books', 'study'];

/// §13.1: "One screen: name, icon, colour, and a frequency row that
/// defaults to Every day. Optional target. Optional reminder. Nothing
/// else." Frequency reuses `RhythmEditor` (§7.3 step 2) rather than a
/// second, smaller rhythm control — one implementation of "how often,"
/// same reasoning as everywhere else this rule engine is surfaced.
class HabitCreateScreen extends ConsumerStatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  ConsumerState<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends ConsumerState<HabitCreateScreen> {
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _targetUnitController = TextEditingController();
  String? _iconName;
  var _colour = 'habits';
  late RecurrenceRule _rule;
  TimeOfDay? _reminderTime;

  CivilDate get _anchor => CivilDate.fromDateTime(DateTime.now());

  @override
  void initState() {
    super.initState();
    _rule = IntervalDays(1, anchor: _anchor);
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final targetValue = double.tryParse(_targetValueController.text.trim());
    final targetUnit = _targetUnitController.text.trim();
    await ref.read(planRepositoryProvider).createPlan(
      userId: userId,
      title: title,
      rule: _rule,
      kind: PlanKind.habit,
      icon: _iconName,
      colour: _colour,
      timeOfDay: _reminderTime == null ? null : _formatTime(_reminderTime!),
      target: (targetValue == null || targetValue <= 0 || targetUnit.isEmpty)
          ? null
          : PlanTarget(value: targetValue, unit: targetUnit),
    );
    if (mounted) Navigator.of(context).pop();
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('New habit')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LifeSpace.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LTextField(controller: _titleController, label: 'Name', outlined: true, autofocus: true),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Icon'),
                    Wrap(
                      spacing: LifeSpace.s8,
                      runSpacing: LifeSpace.s8,
                      children: [
                        for (final entry in planIconOptions.entries)
                          _iconSwatch(context, entry.key, entry.value),
                      ],
                    ),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Colour'),
                    Wrap(
                      spacing: LifeSpace.s8,
                      children: [for (final domain in _colourOptions) _colourSwatch(context, domain)],
                    ),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'How often?'),
                    RhythmEditor(anchor: _anchor, initialRule: _rule, onRuleChanged: (rule) => setState(() => _rule = rule)),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Target (optional)'),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: LTextField(
                            controller: _targetValueController,
                            placeholder: '8',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: LifeSpace.s12),
                        Expanded(
                          child: LTextField(controller: _targetUnitController, placeholder: 'glasses'),
                        ),
                      ],
                    ),
                    const SizedBox(height: LifeSpace.s20),
                    _label(context, 'Reminder (optional)'),
                    LTimePicker(time: _reminderTime, onChanged: (t) => setState(() => _reminderTime = t)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LifeSpace.s20),
              child: LButton(
                label: 'Create',
                onPressed: _titleController.text.trim().isEmpty ? null : _save,
              ),
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

  Widget _iconSwatch(BuildContext context, String name, IconData icon) {
    final colors = context.colors;
    final selected = _iconName == name;
    return GestureDetector(
      onTap: () => setState(() => _iconName = name),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? colors.accent.soft : colors.neutrals.surfaceAlt,
          shape: BoxShape.circle,
          border: selected ? Border.all(color: colors.accent.base, width: 2) : null,
        ),
        child: Icon(icon, color: selected ? colors.accent.base : colors.neutrals.ink2),
      ),
    );
  }

  Widget _colourSwatch(BuildContext context, String domainName) {
    final colour = resolvePlanColour(context, domainName);
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
