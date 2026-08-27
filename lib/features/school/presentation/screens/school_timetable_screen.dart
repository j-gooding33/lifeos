import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/school/application/school_providers.dart';

const _weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// Manual timetable entry (M8 Part 31) — grouped by weekday, split further
/// by Week A/B when the profile is a two-week timetable. Architecture
/// leaves room for a future CSV/image/PDF importer: that would just be
/// another caller of `SchoolRepository.saveLesson`, never inventing
/// timetable data of its own (§16.7's "no fake data" rule extends here).
class SchoolTimetableScreen extends ConsumerWidget {
  const SchoolTimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncProfile = ref.watch(schoolProfileProvider);
    final asyncLessons = ref.watch(schoolLessonsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Timetable')),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your setup.", onRetry: () => ref.invalidate(schoolProfileProvider)),
        data: (profile) {
          if (profile == null) {
            return const LEmptyState(
              icon: Icons.school_outlined,
              title: 'Set up School first',
              message: 'Add your day times and timetable type from School setup.',
            );
          }
          return asyncLessons.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => LErrorState(message: "Couldn't load your timetable.", onRetry: () => ref.invalidate(schoolLessonsProvider)),
            data: (lessons) => _buildList(context, ref, profile, lessons),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final profile = await ref.read(schoolProfileProvider.future);
          if (profile == null || !context.mounted) return;
          unawaited(_LessonFormSheet.show(context, ref, profile: profile));
        },
        tooltip: 'Add lesson',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, AppSchoolProfile profile, List<AppSchoolLesson> lessons) {
    if (lessons.isEmpty) {
      return const LEmptyState(
        icon: Icons.school_outlined,
        title: 'No lessons yet',
        message: 'Add your first lesson with the + button.',
      );
    }
    final weekLabels = profile.isTwoWeek ? const ['A', 'B'] : const ['ALL'];
    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s16),
      children: [
        for (final weekLabel in weekLabels) ...[
          if (profile.isTwoWeek) ...[
            LSectionHeader(title: 'Week $weekLabel'),
            const SizedBox(height: LifeSpace.s8),
          ],
          for (var weekday = 1; weekday <= 7; weekday++)
            ..._dayLessonWidgets(context, ref, profile, lessons, weekLabel, weekday),
        ],
      ],
    );
  }

  List<Widget> _dayLessonWidgets(
    BuildContext context,
    WidgetRef ref,
    AppSchoolProfile profile,
    List<AppSchoolLesson> lessons,
    String weekLabel,
    int weekday,
  ) {
    final dayLessons = lessons.where((l) => l.weekday == weekday && l.weekLabel == weekLabel).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    if (dayLessons.isEmpty) return const [];
    final colors = context.colors;
    return [
      Padding(
        padding: const EdgeInsets.only(top: LifeSpace.s12, bottom: LifeSpace.s4),
        child: Text(_weekdayNames[weekday - 1], style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
      ),
      for (final lesson in dayLessons)
        LListTile(
          title: lesson.subject,
          subtitle: [
            '${lesson.startTime}-${lesson.endTime}',
            if (lesson.teacher != null) lesson.teacher!,
            if (lesson.room != null) lesson.room!,
          ].join('  |  '),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _LessonFormSheet.show(context, ref, profile: profile, existing: lesson),
        ),
    ];
  }
}

class _LessonFormSheet extends ConsumerStatefulWidget {
  const _LessonFormSheet({required this.profile, this.existing});

  final AppSchoolProfile profile;
  final AppSchoolLesson? existing;

  static Future<void> show(BuildContext context, WidgetRef ref, {required AppSchoolProfile profile, AppSchoolLesson? existing}) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.75],
      builder: (context) => _LessonFormSheet(profile: profile, existing: existing),
    );
  }

  @override
  ConsumerState<_LessonFormSheet> createState() => _LessonFormSheetState();
}

class _LessonFormSheetState extends ConsumerState<_LessonFormSheet> {
  late final _subjectController = TextEditingController(text: widget.existing?.subject ?? '');
  late final _teacherController = TextEditingController(text: widget.existing?.teacher ?? '');
  late final _roomController = TextEditingController(text: widget.existing?.room ?? '');
  late var _weekday = widget.existing?.weekday ?? 1;
  late var _weekLabel = widget.existing?.weekLabel ?? (widget.profile.isTwoWeek ? 'A' : 'ALL');
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = _parse(widget.existing?.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = _parse(widget.existing?.endTime) ?? const TimeOfDay(hour: 10, minute: 0);
  }

  TimeOfDay? _parse(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _format(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) return;
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(schoolRepositoryProvider).saveLesson(
      id: widget.existing?.id,
      userId: userId,
      weekLabel: _weekLabel,
      weekday: _weekday,
      subject: subject,
      teacher: _teacherController.text.trim().isEmpty ? null : _teacherController.text.trim(),
      room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
      startTime: _format(_startTime!),
      endTime: _format(_endTime!),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this lesson?', message: 'This cannot be undone.');
    if (!confirmed) return;
    await ref.read(schoolRepositoryProvider).deleteLesson(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: LifeSpace.s20, right: LifeSpace.s20, top: LifeSpace.s20, bottom: MediaQuery.viewInsetsOf(context).bottom + LifeSpace.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.existing == null ? 'New lesson' : 'Edit lesson', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s16),
          LTextField(controller: _subjectController, label: 'Subject', outlined: true, autofocus: true),
          const SizedBox(height: LifeSpace.s12),
          LTextField(controller: _teacherController, label: 'Teacher (optional)', outlined: true),
          const SizedBox(height: LifeSpace.s12),
          LTextField(controller: _roomController, label: 'Room (optional)', outlined: true),
          const SizedBox(height: LifeSpace.s16),
          Text('Day', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s8),
          Wrap(
            spacing: LifeSpace.s8,
            runSpacing: LifeSpace.s8,
            children: [
              for (var i = 1; i <= 7; i++)
                ChoiceChip(
                  label: Text(_weekdayNames[i - 1].substring(0, 3)),
                  selected: _weekday == i,
                  onSelected: (_) => setState(() => _weekday = i),
                ),
            ],
          ),
          if (widget.profile.isTwoWeek) ...[
            const SizedBox(height: LifeSpace.s16),
            LSegmented<String>(
              segments: const {'A': 'Week A', 'B': 'Week B'},
              selected: _weekLabel,
              onChanged: (value) => setState(() => _weekLabel = value),
            ),
          ],
          const SizedBox(height: LifeSpace.s16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Starts', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
                    const SizedBox(height: LifeSpace.s4),
                    LTimePicker(time: _startTime, onChanged: (t) => setState(() => _startTime = t)),
                  ],
                ),
              ),
              const SizedBox(width: LifeSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ends', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
                    const SizedBox(height: LifeSpace.s4),
                    LTimePicker(time: _endTime, onChanged: (t) => setState(() => _endTime = t)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LifeSpace.s24),
          LButton(label: 'Save', onPressed: _save),
          if (widget.existing != null) ...[
            const SizedBox(height: LifeSpace.s8),
            LButton(label: 'Delete lesson', variant: LButtonVariant.destructive, onPressed: _delete),
          ],
        ],
      ),
    );
  }
}
