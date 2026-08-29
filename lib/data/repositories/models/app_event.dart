import 'package:life_os/core/scheduling/civil_date.dart';

/// §14. A calendar item, local or read-only imported from a device
/// calendar via `source = 'device'` (§14.4 — see DECISIONS.md).
/// `startDate`/`endDate` mirror `startAt`/`endAt` for every
/// event, all-day or not, so every calendar view can range-query on the
/// civil date alone rather than branching on `allDay` (§14.5: one range
/// query per period). Recurring events (the table's `recurrenceRule`
/// column) aren't supported yet — every event created here is a single
/// occurrence; only Plans get real recurrence in v1.
class AppEvent {
  AppEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.startAt,
    this.notes,
    this.location,
    this.endAt,
    this.allDay = false,
    this.colour,
    this.source = 'local',
    this.externalId,
    this.externalCalendarId,
    DateTime? createdAt,
  }) : startDate = CivilDate.fromDateTime(startAt),
       endDate = endAt == null ? null : CivilDate.fromDateTime(endAt),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? notes;
  final String? location;
  final DateTime startAt;
  final DateTime? endAt;
  final CivilDate startDate;
  final CivilDate? endDate;
  final bool allDay;
  final String? colour;
  final String source;
  final String? externalId;
  final String? externalCalendarId;
  final DateTime createdAt;

  bool get isFromDevice => source == 'device';

  AppEvent copyWith({
    String? title,
    String? notes,
    String? location,
    DateTime? startAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? allDay,
    String? colour,
  }) {
    return AppEvent(
      id: id,
      userId: userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      startAt: startAt ?? this.startAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      allDay: allDay ?? this.allDay,
      colour: colour ?? this.colour,
      source: source,
      externalId: externalId,
      externalCalendarId: externalCalendarId,
      createdAt: createdAt,
    );
  }
}
