import 'package:life_os/core/calendar/device_calendar_service.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_calendar_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceCalendarService deviceCalendarService(Ref ref) {
  return DeviceCalendarService(ref.watch(appDatabaseProvider));
}

/// A fresh OS-level check each time something watches it (deliberately
/// not `keepAlive`) — permission can change from outside the app (Android
/// Settings), so the Calendar screen's banner should never trust a stale
/// cached answer from the last time it was open.
@riverpod
Future<bool> deviceCalendarPermissionGranted(Ref ref) {
  return ref.watch(deviceCalendarServiceProvider).hasPermission();
}

@riverpod
Future<List<DeviceCalendarInfo>> deviceCalendars(Ref ref) {
  return ref.watch(deviceCalendarServiceProvider).listCalendars();
}

@riverpod
Future<bool> deviceCalendarEnabled(Ref ref, String calendarId) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final enabledIds = await ref.watch(deviceCalendarServiceProvider).enabledCalendarIds(userId);
  return enabledIds.contains(calendarId);
}
