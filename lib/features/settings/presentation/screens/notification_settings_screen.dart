import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/notifications/notification_providers.dart';
import 'package:life_os/core/preferences/preference_toggle.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

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

// These five categories have no generator in NotificationScheduler yet —
// morning/evening briefings and the weekly review need content this app
// doesn't compose yet, free-time nudges need a free-time-detection
// algorithm that doesn't exist, and task deadlines aren't a distinct
// mechanism from task reminders yet. Saved like every other toggle here,
// just not acted on — see DECISIONS.md.
const _unimplementedCategories = {
  'notif.taskDeadlines',
  'notif.morningBriefing',
  'notif.eveningBriefing',
  'notif.freeTimeNudges',
  'notif.weeklyReview',
};

const _masterKey = 'notif.master';
const _quietStartKey = 'notif.quietStart';
const _quietEndKey = 'notif.quietEnd';

/// §22.5, §22.3. Task/plan/habit/event/project/goal reminders are real,
/// scheduled locally (`NotificationScheduler`) — every change here
/// reschedules immediately rather than waiting for the next app resume,
/// so a toggle takes effect right away. Morning/evening briefings, the
/// weekly review and free-time nudges are still preferences-only; see
/// `_unimplementedCategories` and DECISIONS.md.
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
              'Task, plan, habit, event, project and goal reminders are scheduled on this device. '
              "Briefings, the weekly review and free-time nudges are saved but don't fire yet.",
              style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
            ),
          ),
          const SizedBox(height: LifeSpace.cardGap),
          LListTile(
            title: 'Notifications',
            subtitle: 'Master switch for everything below.',
            trailing: Switch(
              value: master,
              onChanged: (v) async {
                await setBoolPreference(ref, _masterKey, value: v);
                await _reschedule(ref);
              },
            ),
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

Future<void> _reschedule(WidgetRef ref) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  final userId = await ref.read(currentUserIdProvider.future);
  await scheduler.rescheduleAll(userId);
}

class _CategoryToggle extends ConsumerWidget {
  const _CategoryToggle({required this.prefKey, required this.label, required this.enabled});

  final String prefKey;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(boolPreferenceProvider(prefKey)).value ?? false;
    final implemented = !_unimplementedCategories.contains(prefKey);
    return LListTile(
      title: label,
      subtitle: implemented ? null : 'Saved, not scheduled yet',
      trailing: Switch(
        value: enabled && value,
        onChanged: enabled
            ? (v) async {
                await setBoolPreference(ref, prefKey, value: v);
                if (implemented) await _reschedule(ref);
              }
            : null,
      ),
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
        Expanded(
          child: _TimeField(
            label: 'Starts',
            value: start,
            onPick: (v) async {
              await setStringPreference(ref, _quietStartKey, v);
              await _reschedule(ref);
            },
          ),
        ),
        const SizedBox(width: LifeSpace.s12),
        Expanded(
          child: _TimeField(
            label: 'Ends',
            value: end,
            onPick: (v) async {
              await setStringPreference(ref, _quietEndKey, v);
              await _reschedule(ref);
            },
          ),
        ),
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
