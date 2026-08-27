import 'package:drift/drift.dart';

/// M8 Part 30-31. One row per recurring timetable slot: "Week A, Monday,
/// 09:00-10:00, Maths". The real calendar dates this applies to are
/// derived at read time by `school_week_engine.dart`, not stored — the
/// same "generate, don't persist, the obviously-computable" choice as the
/// unified calendar's merge, just for a weekly-repeating source instead of
/// a dated one.
class SchoolLessons extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// `A` | `B` for a two-week timetable, `ALL` for a one-week one.
  TextColumn get weekLabel => text()();

  /// ISO weekday, Monday = 1.
  IntColumn get weekday => integer()();
  TextColumn get subject => text()();
  TextColumn get teacher => text().nullable()();
  TextColumn get room => text().nullable()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get colour => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
