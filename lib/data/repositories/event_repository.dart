import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_event.dart';
import 'package:uuid/uuid.dart';

/// §14. Local events only — device-calendar read-only import is deferred
/// (see DECISIONS.md), so every row here has `source == 'local'`.
class EventRepository {
  EventRepository(this._dao);

  final EventDao _dao;

  Stream<List<AppEvent>> watchInRange(
    String userId,
    CivilDate from,
    CivilDate through,
  ) {
    return _dao
        .watchInRange(userId, from.toIso(), through.toIso())
        .map(_toDomainList);
  }

  Stream<AppEvent?> watchById(String id) {
    return _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));
  }

  Future<Result<AppEvent, Failure>> createEvent({
    required String userId,
    required String title,
    required DateTime startAt,
    DateTime? endAt,
    bool allDay = false,
    String? notes,
    String? location,
    String? colour,
  }) async {
    try {
      final event = AppEvent(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        startAt: startAt,
        endAt: endAt,
        allDay: allDay,
        notes: notes,
        location: location,
        colour: colour,
      );
      await _save(event);
      return Ok(event);
    } on Object catch (e) {
      return Err(DatabaseFailure('createEvent failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateEvent(AppEvent event) async {
    try {
      await _save(event);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateEvent failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteEvent(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteEvent failed: $e'));
    }
  }

  Future<void> _save(AppEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.EventsCompanion(
        id: Value(event.id),
        userId: Value(event.userId),
        title: Value(event.title),
        notes: Value(event.notes),
        location: Value(event.location),
        startAt: Value(event.startAt.millisecondsSinceEpoch),
        endAt: Value(event.endAt?.millisecondsSinceEpoch),
        startDate: Value(event.startDate.toIso()),
        endDate: Value(event.endDate?.toIso()),
        allDay: Value(event.allDay),
        colour: Value(event.colour),
        source: Value(event.source),
        externalId: Value(event.externalId),
        createdAt: Value(event.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppEvent> _toDomainList(List<db.Event> rows) =>
      rows.map(_toDomain).toList();

  AppEvent _toDomain(db.Event row) {
    return AppEvent(
      id: row.id,
      userId: row.userId,
      title: row.title,
      notes: row.notes,
      location: row.location,
      startAt: row.startAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(row.startAt!),
      endAt: row.endAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.endAt!),
      allDay: row.allDay,
      colour: row.colour,
      source: row.source,
      externalId: row.externalId,
      createdAt: row.createdAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }
}
