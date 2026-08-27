import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/application/plan_templates.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/widgets/rhythm_editor.dart';
import 'package:life_os/features/plans/presentation/widgets/step_control.dart';

/// §7.3: three steps, each one screen, hosted here as one wizard so
/// "create from step 2 alone by tapping Create" (step 3 is entirely
/// optional) is a single always-visible action rather than a separate
/// route per step. [planId] switches this into edit mode.
class PlanCreateScreen extends ConsumerStatefulWidget {
  const PlanCreateScreen({this.planId, super.key});

  final String? planId;

  @override
  ConsumerState<PlanCreateScreen> createState() => _PlanCreateScreenState();
}

class _PlanCreateScreenState extends ConsumerState<PlanCreateScreen> {
  var _step = 0;
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  PlanTemplate? _template;
  String? _iconName;
  String? _colour;
  String? _category;
  String? _mediaType;
  RecurrenceRule? _rule;
  TimeOfDay? _timeOfDay;
  var _durationMinutes = 0;
  var _missedPolicy = MissedPolicy.markMissed;
  var _scheduleMode = ScheduleMode.fixed;
  DateTime? _endDate;

  var _loaded = false;
  AppPlan? _existing;

  bool get _isNew => widget.planId == null;
  CivilDate get _anchor =>
      _existing?.rule.anchor ?? CivilDate.fromDateTime(DateTime.now());

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyTemplate(PlanTemplate template) {
    setState(() {
      _template = template;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = template.title;
      }
      _iconName = template.iconName;
      _colour = template.colour;
      _category = template.category;
      _mediaType = template.mediaType;
      _rule = template.suggestedRule(_anchor);
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _rule == null) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final repository = ref.read(planRepositoryProvider);

    if (_existing != null) {
      final updated = _existing!.copyWith(
        title: title,
        icon: _iconName,
        colour: _colour,
        category: _category,
        mediaType: _mediaType,
        rule: _rule,
        timeOfDay: _timeOfDay == null ? null : _formatTime(_timeOfDay!),
        durationMinutes: _durationMinutes == 0 ? null : _durationMinutes,
        missedPolicy: _missedPolicy,
        scheduleMode: _scheduleMode,
        endDate: _endDate == null ? null : CivilDate.fromDateTime(_endDate!),
        clearEndDate: _endDate == null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      await repository.updatePlan(_existing!, updated);
    } else {
      await repository.createPlan(
        userId: userId,
        title: title,
        rule: _rule!,
        icon: _iconName,
        colour: _colour,
        category: _category,
        mediaType: _mediaType,
        timeOfDay: _timeOfDay == null ? null : _formatTime(_timeOfDay!),
        durationMinutes: _durationMinutes == 0 ? null : _durationMinutes,
        missedPolicy: _missedPolicy,
        scheduleMode: _scheduleMode,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }
    if (mounted) context.pop();
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_isNew) return _buildScaffold(context);

    final asyncPlan = ref.watch(planByIdProvider(widget.planId!));
    return asyncPlan.when(
      loading: () =>
          const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: const LErrorState(message: "Couldn't load this plan."),
      ),
      data: (plan) {
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const LErrorState(message: 'This plan no longer exists.'),
          );
        }
        if (!_loaded) {
          _existing = plan;
          _titleController.text = plan.title;
          _notesController.text = plan.notes ?? '';
          _iconName = plan.icon;
          _colour = plan.colour;
          _category = plan.category;
          _mediaType = plan.mediaType;
          _rule = plan.rule;
          _timeOfDay = plan.timeOfDay == null
              ? null
              : _parseTime(plan.timeOfDay!);
          _durationMinutes = plan.durationMinutes ?? 0;
          _missedPolicy = plan.missedPolicy;
          _scheduleMode = plan.scheduleMode;
          _endDate = plan.endDate == null
              ? null
              : DateTime(
                  plan.endDate!.year,
                  plan.endDate!.month,
                  plan.endDate!.day,
                );
          _loaded = true;
        }
        return _buildScaffold(context);
      },
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildScaffold(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text(_isNew ? 'New plan' : 'Edit plan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(LifeSpace.s20),
                child: switch (_step) {
                  0 => _buildWhatStep(context),
                  1 => RhythmEditor(
                    anchor: _anchor,
                    initialRule: _rule,
                    onRuleChanged: (rule) => setState(() => _rule = rule),
                  ),
                  _ => _buildDetailsStep(context),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LifeSpace.s20),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: LButton(
                        label: 'Back',
                        variant: LButtonVariant.tonal,
                        onPressed: () => setState(() => _step -= 1),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: LifeSpace.s12),
                  if (_step < 2)
                    Expanded(
                      child: LButton(
                        label: 'Next',
                        onPressed: _canAdvance
                            ? () => setState(() => _step += 1)
                            : null,
                      ),
                    ),
                  if (_step >= 1) ...[
                    const SizedBox(width: LifeSpace.s12),
                    Expanded(
                      child: LButton(
                        label: _isNew ? 'Create' : 'Save',
                        variant: _step < 2
                            ? LButtonVariant.tonal
                            : LButtonVariant.filled,
                        onPressed: _canAdvance ? _save : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canAdvance {
    if (_step == 0) return _titleController.text.trim().isNotEmpty;
    return _rule != null;
  }

  Widget _buildWhatStep(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you building?',
          style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
        ),
        const SizedBox(height: LifeSpace.s16),
        LTextField(
          controller: _titleController,
          placeholder: 'Title',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: LifeSpace.s20),
        Text(
          'Templates',
          style: context.textStyles.subhead.copyWith(
            color: colors.neutrals.ink2,
          ),
        ),
        const SizedBox(height: LifeSpace.s8),
        Wrap(
          spacing: LifeSpace.s8,
          runSpacing: LifeSpace.s8,
          children: [
            for (final template in PlanTemplate.all)
              LChip(
                label: template.title,
                icon: planIconFor(template.iconName),
                selected: _template == template,
                onTap: () => _applyTemplate(template),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsStep(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
        ),
        const SizedBox(height: LifeSpace.s4),
        Text(
          'Everything below is optional.',
          style: context.textStyles.callout.copyWith(
            color: colors.neutrals.ink2,
          ),
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'Time of day'),
        LTimePicker(
          time: _timeOfDay,
          onChanged: (t) => setState(() => _timeOfDay = t),
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'Duration (minutes)'),
        StepControl(
          value: _durationMinutes,
          min: 0,
          max: 480,
          onChanged: (v) => setState(() => _durationMinutes = v),
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'If a day is missed'),
        LSegmented<MissedPolicy>(
          segments: const {
            MissedPolicy.skip: 'Skip',
            MissedPolicy.markMissed: 'Mark missed',
            MissedPolicy.rollForward: 'Roll forward',
          },
          selected: _missedPolicy,
          onChanged: (v) => setState(() => _missedPolicy = v),
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'Scheduling'),
        LSegmented<ScheduleMode>(
          segments: const {
            ScheduleMode.fixed: 'Count from the schedule',
            ScheduleMode.rolling: 'Count from when I last did it',
          },
          selected: _scheduleMode,
          onChanged: (v) => setState(() => _scheduleMode = v),
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'Colour'),
        Wrap(
          spacing: LifeSpace.s8,
          children: [
            for (final domain in const [
              'plans',
              'films',
              'books',
              'study',
              'habits',
            ])
              _colourSwatch(context, domain),
          ],
        ),
        const SizedBox(height: LifeSpace.s20),
        _label(context, 'Notes'),
        LTextField(controller: _notesController, placeholder: 'Notes'),
      ],
    );
  }

  Widget _label(BuildContext context, String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: LifeSpace.s8),
      child: Text(
        text,
        style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2),
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
          border: selected
              ? Border.all(color: context.colors.neutrals.ink, width: 2)
              : null,
        ),
      ),
    );
  }
}
