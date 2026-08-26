import 'package:drift/drift.dart';

/// §23.3, §10.2. One-off actions with an optional deadline.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get dueTime => text().nullable()();
  TextColumn get timezone => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable()();
  TextColumn get projectId => text().nullable()();
  TextColumn get goalId => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get parentRecurringId => text().nullable()();
  RealColumn get sortIndex => real().withDefault(const Constant(0))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
