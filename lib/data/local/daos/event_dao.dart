import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/events_table.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [Events])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(super.db);

  /// One range query per visible period (§14.5).
  Stream<List<Event>> watchInRange(String userId, String from, String through) {
    final query = select(events)
      ..where(
        (e) =>
            e.userId.equals(userId) &
            e.deletedAt.isNull() &
            e.startDate.isBiggerOrEqualValue(from) &
            e.startDate.isSmallerOrEqualValue(through),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.startAt)]);
    return query.watch();
  }

  Future<Event?> getById(String id) =>
      (select(events)..where((e) => e.id.equals(id))).getSingleOrNull();

  Stream<Event?> watchById(String id) =>
      (select(events)..where((e) => e.id.equals(id))).watchSingleOrNull();

  Future<void> upsert(EventsCompanion entry) =>
      into(events).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(events)..where((e) => e.id.equals(id))).write(
        EventsCompanion(deletedAt: Value(now)),
      );

  /// §14.4. Device-imported rows are a read-only mirror, not user data —
  /// hard-deleted outright rather than soft-deleted, since there's nothing
  /// to recover: re-enabling the calendar just re-imports them.
  Future<void> deleteDeviceEventsForCalendar(String userId, String externalCalendarId) =>
      (delete(events)..where(
            (e) => e.userId.equals(userId) & e.source.equals('device') & e.externalCalendarId.equals(externalCalendarId),
          ))
          .go();

  Future<void> deleteAllDeviceEvents(String userId) =>
      (delete(events)..where((e) => e.userId.equals(userId) & e.source.equals('device'))).go();
}
