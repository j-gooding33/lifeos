import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/preference_toggle.dart';

const _categories = {
  'notif.taskReminders': 'Task reminders',
  'notif.taskDeadlines': 'Task deadlines',
  'notif.planOccurrences': 'Plan occurrences',
  'notif.habitReminders': 'Habit reminders',
  'notif.eventAlerts': 'Event alerts',
  'notif.projectDeadlines': 'Project deadlines',
  'notif.goalMilestones': 'Goal milestones',
  'notif.morningBriefing': 'Morning briefing',
  'notif.eveningBriefing': 'Evening briefing',
  'notif.freeTimeNudges': 'Free-time nudges',
  'notif.weeklyReview': 'Weekly review',
};

const _masterKey = 'notif.master';
const _quietStartKey = 'notif.quietStart';
const _quietEndKey = 'notif.quietEnd';

/// §22.5, §22.3. Preferences UI only — no `flutter_local_notifications`
/// wiring, so nothing actually fires yet (same "shell now, backend later"
/// shape as Settings → AI). Every switch here saves a real preference so
/// nothing needs re-asking once a `NotificationScheduler` exists.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final master = ref.watch(boolPreferenceProvider(_masterKey)).value ?? false;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          LCard(
            child: Text(
              "Notifications aren't scheduled yet — this app doesn't have a delivery mechanism wired up. "
              'These preferences are saved now and take effect as soon as it does.',
              style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
            ),
          ),
          const SizedBox(height: LifeSpace.cardGap),
          LListTile(
            title: 'Notifications',
            subtitle: 'Master switch for everything below.',
            trailing: Switch(value: master, onChanged: (v) => setBoolPreference(ref, _masterKey, value: v)),
          ),
          const SizedBox(height: LifeSpace.s16),
          const LSectionHeader(title: 'Categories'),
          const SizedBox(height: LifeSpace.s8),
          for (final entry in _categories.entries) _CategoryToggle(prefKey: entry.key, label: entry.value, enabled: master),
          const SizedBox(height: LifeSpace.s16),
          const LSectionHeader(title: 'Quiet hours'),
          const SizedBox(height: LifeSpace.s8),
          _QuietHoursRow(),
        ],
      ),
    );
  }
}

class _CategoryToggle extends ConsumerWidget {
  const _CategoryToggle({required this.prefKey, required this.label, required this.enabled});

  final String prefKey;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(boolPreferenceProvider(prefKey)).value ?? false;
    return LListTile(
      title: label,
      trailing: Switch(value: enabled && value, onChanged: enabled ? (v) => setBoolPreference(ref, prefKey, value: v) : null),
    );
  }
}

class _QuietHoursRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(stringPreferenceProvider(_quietStartKey)).value;
    final end = ref.watch(stringPreferenceProvider(_quietEndKey)).value;
    return Row(
      children: [
        Expanded(child: _TimeField(label: 'Starts', value: start, onPick: (v) => setStringPreference(ref, _quietStartKey, v))),
        const SizedBox(width: LifeSpace.s12),
        Expanded(child: _TimeField(label: 'Ends', value: end, onPick: (v) => setStringPreference(ref, _quietEndKey, v))),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, required this.onPick});

  final String label;
  final String? value;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LCard(
      onTap: () async {
        final parts = value?.split(':');
        final initial = parts != null && parts.length == 2
            ? TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))
            : const TimeOfDay(hour: 22, minute: 0);
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          onPick('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s4),
          Text(value ?? 'Select a time', style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
        ],
      ),
    );
  }
}
