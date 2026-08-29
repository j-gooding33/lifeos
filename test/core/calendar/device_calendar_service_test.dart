import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/calendar/device_calendar_service.dart';
import 'package:timezone/timezone.dart' as tz;

dc.Event _event({String? eventId = 'e1', String? title = 'Dentist', tz.TZDateTime? start, tz.TZDateTime? end, bool? allDay}) {
  return dc.Event('cal1', eventId: eventId, title: title, start: start ?? tz.TZDateTime.utc(2026, 3, 1, 9), end: end, allDay: allDay);
}

void main() {
  test('a well-formed device event maps to a device-sourced AppEvent with a deterministic id', () {
    final mapped = mapDeviceEvent(_event(), calendarId: 'cal1', userId: 'u1');
    expect(mapped, isNotNull);
    expect(mapped!.id, 'device:cal1:e1');
    expect(mapped.title, 'Dentist');
    expect(mapped.source, 'device');
    expect(mapped.externalId, 'e1');
    expect(mapped.externalCalendarId, 'cal1');
    expect(mapped.isFromDevice, isTrue);
  });

  test('an event with no id is dropped rather than crashing', () {
    expect(mapDeviceEvent(_event(eventId: null), calendarId: 'cal1', userId: 'u1'), isNull);
  });

  test('an event with no start time is dropped rather than crashing', () {
    final blank = dc.Event('cal1', eventId: 'e2', title: 'No start');
    expect(mapDeviceEvent(blank, calendarId: 'cal1', userId: 'u1'), isNull);
  });

  test('an untitled device event still gets a real title, not a blank one', () {
    final mapped = mapDeviceEvent(_event(title: ''), calendarId: 'cal1', userId: 'u1');
    expect(mapped!.title, '(untitled)');
  });

  test('two calendars can each contribute an event with the same underlying eventId without colliding', () {
    final a = mapDeviceEvent(_event(), calendarId: 'cal1', userId: 'u1');
    final b = mapDeviceEvent(_event(), calendarId: 'cal2', userId: 'u1');
    expect(a!.id, isNot(b!.id));
  });
}
