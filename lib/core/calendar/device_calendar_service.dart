import 'dart:convert';

import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter/foundation.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/event_repository.dart';
import 'package:life_os/data/repositories/models/app_event.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

const _masterKey = 'calendar.device.master';
const _enabledIdsKey = 'calendar.device.enabledIds';

/// One row for the Settings → Calendar list — deliberately not the
/// package's own `Calendar` model, so nothing outside this file needs to
/// import `device_calendar`.
class DeviceCalendarInfo {
  DeviceCalendarInfo({required this.id, required this.name, required this.accountName});

  final String id;
  final String name;
  final String? accountName;
}

/// §14.4. Read-only import from the device's own calendars, opt-in behind
/// a master switch plus a per-calendar toggle — nothing here ever calls
/// the plugin's `createOrUpdateEvent`/`deleteEvent`; two-way sync is
/// explicitly postponed (§37.2). Imported rows live in the same `events`
/// table as the user's own (`EventRepository`, `source == 'device'`), so
/// every calendar view renders both from the one query §14.5 already
/// requires — see DECISIONS.md.
class DeviceCalendarService {
  DeviceCalendarService(AppDatabase db)
    : _eventRepository = EventRepository(EventDao(db)),
      _preferencesRepository = PreferencesRepository(PreferencesDao(db));

  final EventRepository _eventRepository;
  final PreferencesRepository _preferencesRepository;
  final _plugin = dc.DeviceCalendarPlugin();

  static const _importHorizonBack = Duration(days: 30);
  static const _importHorizonForward = Duration(days: 180);

  Future<bool> hasPermission() async {
    final result = await _plugin.hasPermissions();
    return result.data ?? false;
  }

  /// device_calendar checks read AND write permission together (no
  /// read-only request exists in its API) — Life OS never actually writes
  /// to the device calendar, but Android has no way to grant only one.
  /// See DECISIONS.md.
  Future<bool> requestPermission() async {
    final result = await _plugin.requestPermissions();
    return result.data ?? false;
  }

  Future<List<DeviceCalendarInfo>> listCalendars() async {
    final result = await _plugin.retrieveCalendars();
    return [
      for (final calendar in result.data ?? const <dc.Calendar>[])
        if (calendar.id != null) DeviceCalendarInfo(id: calendar.id!, name: calendar.name ?? 'Calendar', accountName: calendar.accountName),
    ];
  }

  Future<bool> isMasterEnabled(String userId) async {
    final result = await _preferencesRepository.get(userId, _masterKey);
    return result.when(ok: (v) => v == 'true', err: (_) => false);
  }

  Future<void> setMasterEnabled(String userId, {required bool enabled}) => _preferencesRepository.set(userId, _masterKey, enabled.toString());

  Future<Set<String>> enabledCalendarIds(String userId) async {
    final result = await _preferencesRepository.get(userId, _enabledIdsKey);
    final raw = result.when(ok: (v) => v, err: (_) => null);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as List<Object?>).cast<String>().toSet();
  }

  Future<void> setCalendarEnabled(String userId, String calendarId, {required bool enabled}) async {
    final current = await enabledCalendarIds(userId);
    if (enabled) {
      current.add(calendarId);
    } else {
      current.remove(calendarId);
    }
    await _preferencesRepository.set(userId, _enabledIdsKey, jsonEncode(current.toList()));
  }

  /// Cancels the whole imported mirror (master off, or permission was
  /// revoked from outside the app since it was last granted) or replaces
  /// each enabled calendar's imported events wholesale — cheap enough at
  /// personal-app scale to not bother diffing against what's already
  /// there, same call as `NotificationScheduler.rescheduleAll`.
  Future<void> sync(String userId) async {
    if (!await isMasterEnabled(userId) || !await hasPermission()) {
      await _eventRepository.clearDeviceEvents(userId);
      return;
    }

    final enabledIds = await enabledCalendarIds(userId);
    final calendars = await listCalendars();
    final now = DateTime.now();
    final start = now.subtract(_importHorizonBack);
    final end = now.add(_importHorizonForward);

    for (final calendar in calendars) {
      if (!enabledIds.contains(calendar.id)) {
        await _eventRepository.replaceDeviceEvents(userId, calendar.id, const []);
        continue;
      }
      final result = await _plugin.retrieveEvents(calendar.id, dc.RetrieveEventsParams(startDate: start, endDate: end));
      final mapped = [
        for (final event in result.data ?? const <dc.Event>[])
          if (mapDeviceEvent(event, calendarId: calendar.id, userId: userId) case final appEvent?) appEvent,
      ];
      await _eventRepository.replaceDeviceEvents(userId, calendar.id, mapped);
    }
  }
}

/// The candidate-mapping half, with no plugin call in it — a test can
/// build a `device_calendar` `Event` directly and assert on the result,
/// same split as `NotificationScheduler.buildSchedule`.
@visibleForTesting
AppEvent? mapDeviceEvent(dc.Event event, {required String calendarId, required String userId}) {
  final eventId = event.eventId;
  final start = event.start;
  if (eventId == null || start == null) return null;
  return AppEvent(
    id: 'device:$calendarId:$eventId',
    userId: userId,
    title: (event.title?.isNotEmpty ?? false) ? event.title! : '(untitled)',
    notes: event.description,
    location: event.location,
    startAt: start,
    endAt: event.end,
    allDay: event.allDay ?? false,
    source: 'device',
    externalId: eventId,
    externalCalendarId: calendarId,
  );
}
