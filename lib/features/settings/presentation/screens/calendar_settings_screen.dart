import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/calendar/device_calendar_providers.dart';
import 'package:life_os/core/calendar/device_calendar_service.dart';
import 'package:life_os/core/preferences/preference_toggle.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

const _masterKey = 'calendar.device.master';

/// §14.4, §22.5. Read-only device calendar import: a master switch that
/// doubles as the OS permission request (device_calendar has no
/// read-only-only request — see DECISIONS.md), then a per-calendar toggle
/// list. Every toggle here resyncs immediately, same "takes effect right
/// away" rule the notification toggles use.
class CalendarSettingsScreen extends ConsumerWidget {
  const CalendarSettingsScreen({super.key});

  Future<void> _toggleMaster(WidgetRef ref, {required bool value}) async {
    final service = ref.read(deviceCalendarServiceProvider);
    final userId = await ref.read(currentUserIdProvider.future);
    if (value) {
      final granted = await service.requestPermission();
      if (!granted) return;
    }
    await service.setMasterEnabled(userId, enabled: value);
    await service.sync(userId);
    ref
      ..invalidate(deviceCalendarsProvider)
      ..invalidate(deviceCalendarPermissionGrantedProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final master = ref.watch(boolPreferenceProvider(_masterKey)).value ?? false;
    final permissionGranted = ref.watch(deviceCalendarPermissionGrantedProvider).value ?? false;
    final active = master && permissionGranted;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          LCard(
            child: Text(
              "Import your device's calendars, read-only — Life OS never changes or deletes anything on the device side. "
              'Two-way sync is not built.',
              style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
            ),
          ),
          const SizedBox(height: LifeSpace.cardGap),
          LListTile(
            title: 'Device calendar',
            subtitle: master && !permissionGranted ? 'Permission was turned off outside the app' : 'Master switch for everything below.',
            trailing: Switch(value: master, onChanged: (v) => _toggleMaster(ref, value: v)),
          ),
          if (active) ...[
            const SizedBox(height: LifeSpace.s16),
            const LSectionHeader(title: 'Calendars'),
            const SizedBox(height: LifeSpace.s8),
            Consumer(
              builder: (context, ref, _) {
                final calendars = ref.watch(deviceCalendarsProvider);
                return calendars.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(LifeSpace.s24),
                    child: Center(child: LLoadingShimmer(width: 200)),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(LifeSpace.s16),
                    child: Text(
                      "Couldn't load your device's calendars.",
                      style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return const LEmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'No calendars found',
                        message: "Your device doesn't have any calendars to import.",
                      );
                    }
                    return Column(children: [for (final calendar in list) _CalendarToggle(calendar: calendar)]);
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarToggle extends ConsumerWidget {
  const _CalendarToggle({required this.calendar});

  final DeviceCalendarInfo calendar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(deviceCalendarEnabledProvider(calendar.id));
    return LListTile(
      title: calendar.name,
      subtitle: calendar.accountName,
      trailing: Switch(
        value: enabledAsync.value ?? false,
        onChanged: enabledAsync.isLoading
            ? null
            : (v) async {
                final service = ref.read(deviceCalendarServiceProvider);
                final userId = await ref.read(currentUserIdProvider.future);
                await service.setCalendarEnabled(userId, calendar.id, enabled: v);
                await service.sync(userId);
                ref.invalidate(deviceCalendarEnabledProvider(calendar.id));
              },
      ),
    );
  }
}
