import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/school/school_week_engine.dart';
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_time_picker.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/school/application/school_providers.dart';

/// M8 Part 30 — school name, day start/end, timetable type, and (for a
/// two-week timetable) the anchor date/label the whole Week A/B
/// computation counts from. Pre-fills from the existing profile if one
/// exists (this screen doubles as "edit setup").
class SchoolSetupScreen extends ConsumerStatefulWidget {
  const SchoolSetupScreen({super.key});

  @override
  ConsumerState<SchoolSetupScreen> createState() => _SchoolSetupScreenState();
}

class _SchoolSetupScreenState extends ConsumerState<SchoolSetupScreen> {
  final _nameController = TextEditingController();
  TimeOfDay? _dayStart;
  TimeOfDay? _dayEnd;
  var _timetableType = SchoolTimetableType.twoWeek;
  var _anchorLabel = WeekLabel.a;
  DateTime? _anchorDate;
  var _loaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  DateTime _toDateTime(CivilDate date) => DateTime(date.year, date.month, date.day);

  Future<void> _save() async {
    final userId = await ref.read(currentUserIdProvider.future);
    final profile = AppSchoolProfile(
      userId: userId,
      schoolName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      dayStartTime: _dayStart == null ? null : _formatTime(_dayStart!),
      dayEndTime: _dayEnd == null ? null : _formatTime(_dayEnd!),
      timetableType: _timetableType,
      anchorWeekLabel: _anchorLabel,
      anchorDate: _anchorDate == null ? null : CivilDate.fromDateTime(_anchorDate!).toIso(),
    );
    await ref.read(schoolRepositoryProvider).saveProfile(profile);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asyncProfile = ref.watch(schoolProfileProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('School setup')),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text("Couldn't load your setup.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (profile) {
          if (!_loaded && profile != null) {
            _nameController.text = profile.schoolName ?? '';
            _dayStart = _parseTime(profile.dayStartTime);
            _dayEnd = _parseTime(profile.dayEndTime);
            _timetableType = profile.timetableType;
            _anchorLabel = profile.anchorWeekLabel;
            _anchorDate = profile.anchorDate == null ? null : _toDateTime(CivilDate.parse(profile.anchorDate!));
            _loaded = true;
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      children: [
        LTextField(controller: _nameController, label: 'School name', outlined: true),
        const SizedBox(height: LifeSpace.s24),
        const LSectionHeader(title: 'School day'),
        const SizedBox(height: LifeSpace.s8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starts', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
                  const SizedBox(height: LifeSpace.s4),
                  LTimePicker(time: _dayStart, onChanged: (t) => setState(() => _dayStart = t)),
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
                  LTimePicker(time: _dayEnd, onChanged: (t) => setState(() => _dayEnd = t)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: LifeSpace.s24),
        const LSectionHeader(title: 'Timetable'),
        const SizedBox(height: LifeSpace.s8),
        LSegmented<SchoolTimetableType>(
          segments: const {SchoolTimetableType.twoWeek: 'Two-week (A/B)', SchoolTimetableType.oneWeek: 'One-week'},
          selected: _timetableType,
          onChanged: (value) => setState(() => _timetableType = value),
        ),
        if (_timetableType == SchoolTimetableType.twoWeek) ...[
          const SizedBox(height: LifeSpace.s20),
          Text(
            'Pick a real date and which week it was, so the timetable can work out every other week from it.',
            style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
          ),
          const SizedBox(height: LifeSpace.s12),
          LDatePicker(date: _anchorDate, onChanged: (d) => setState(() => _anchorDate = d)),
          const SizedBox(height: LifeSpace.s12),
          LSegmented<WeekLabel>(
            segments: const {WeekLabel.a: 'That was Week A', WeekLabel.b: 'That was Week B'},
            selected: _anchorLabel,
            onChanged: (value) => setState(() => _anchorLabel = value),
          ),
        ],
        const SizedBox(height: LifeSpace.s32),
        LButton(label: 'Save', onPressed: _save),
      ],
    );
  }
}
