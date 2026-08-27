import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/school_closures_table.dart';
import 'package:life_os/data/local/tables/school_events_table.dart';
import 'package:life_os/data/local/tables/school_lessons_table.dart';
import 'package:life_os/data/local/tables/school_profile_table.dart';
import 'package:life_os/data/local/tables/school_terms_table.dart';

part 'school_dao.g.dart';

/// One DAO across all five School tables (M8 Parts 30-34) — they're always
/// read/written together (a timetable is meaningless without its profile's
/// anchor, a dashboard needs lessons + terms + closures + events at once),
/// so splitting into five DAOs would just mean every caller injects five
/// objects instead of one.
@DriftAccessor(tables: [SchoolProfile, SchoolLessons, SchoolTerms, SchoolClosures, SchoolEvents])
class SchoolDao extends DatabaseAccessor<AppDatabase> with _$SchoolDaoMixin {
  SchoolDao(super.db);

  Stream<SchoolProfileData?> watchProfile(String userId) {
    final query = select(schoolProfile)..where((p) => p.userId.equals(userId));
    return query.watchSingleOrNull();
  }

  Future<void> upsertProfile(SchoolProfileCompanion entry) =>
      into(schoolProfile).insertOnConflictUpdate(entry);

  Stream<List<SchoolLesson>> watchLessons(String userId) {
    final query = select(schoolLessons)
      ..where((l) => l.userId.equals(userId) & l.deletedAt.isNull())
      ..orderBy([(l) => OrderingTerm.asc(l.weekday), (l) => OrderingTerm.asc(l.startTime)]);
    return query.watch();
  }

  Future<void> upsertLesson(SchoolLessonsCompanion entry) =>
      into(schoolLessons).insertOnConflictUpdate(entry);

  Future<void> deleteLesson(String id, int now) =>
      (update(schoolLessons)..where((l) => l.id.equals(id))).write(SchoolLessonsCompanion(deletedAt: Value(now)));

  Stream<List<SchoolTerm>> watchTerms(String userId) {
    final query = select(schoolTerms)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.startDate)]);
    return query.watch();
  }

  Future<void> upsertTerm(SchoolTermsCompanion entry) => into(schoolTerms).insertOnConflictUpdate(entry);

  Future<void> deleteTerm(String id, int now) =>
      (update(schoolTerms)..where((t) => t.id.equals(id))).write(SchoolTermsCompanion(deletedAt: Value(now)));

  Stream<List<SchoolClosure>> watchClosures(String userId) {
    final query = select(schoolClosures)
      ..where((c) => c.userId.equals(userId) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.startDate)]);
    return query.watch();
  }

  Future<void> upsertClosure(SchoolClosuresCompanion entry) =>
      into(schoolClosures).insertOnConflictUpdate(entry);

  Future<void> deleteClosure(String id, int now) =>
      (update(schoolClosures)..where((c) => c.id.equals(id))).write(SchoolClosuresCompanion(deletedAt: Value(now)));

  Stream<List<SchoolEvent>> watchEvents(String userId) {
    final query = select(schoolEvents)
      ..where((e) => e.userId.equals(userId) & e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm.asc(e.date)]);
    return query.watch();
  }

  Stream<List<SchoolEvent>> watchEventsInRange(String userId, String from, String through) {
    final query = select(schoolEvents)
      ..where(
        (e) =>
            e.userId.equals(userId) &
            e.deletedAt.isNull() &
            e.date.isBiggerOrEqualValue(from) &
            e.date.isSmallerOrEqualValue(through),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.date)]);
    return query.watch();
  }

  Future<void> upsertEvent(SchoolEventsCompanion entry) => into(schoolEvents).insertOnConflictUpdate(entry);

  Future<void> deleteEvent(String id, int now) =>
      (update(schoolEvents)..where((e) => e.id.equals(id))).write(SchoolEventsCompanion(deletedAt: Value(now)));
}
