import 'package:drift/drift.dart';

/// M8 Part 34. A one-off school item on a specific date — a test, an exam,
/// homework due, or a general event — as distinct from the recurring
/// weekly `school_lessons`.
class SchoolEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();

  /// `test` | `exam` | `homework` | `event`.
  TextColumn get type => text().withDefault(const Constant('event'))();
  TextColumn get date => text()();
  TextColumn get time => text().nullable()();
  TextColumn get subject => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
