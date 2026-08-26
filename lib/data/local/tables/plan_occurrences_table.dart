import 'package:drift/drift.dart';

/// §23.3, §8.1. A real, individually editable row — never a computed view.
/// Generated ids are uuidV5 (§9.7); the uniqueness/date indexes that make
/// that scheme safe live in `data/local/migrations/` since they need
/// partial-index `WHERE` clauses Drift's table-level index annotations
/// don't express.
class PlanOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get userId => text()();
  TextColumn get scheduledDate => text()();
  TextColumn get scheduledTime => text().nullable()();
  TextColumn get originalDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get completedAt => integer().nullable()();
  RealColumn get valueAchieved => real().nullable()();
  TextColumn get linkedEntityType => text().nullable()();
  TextColumn get linkedEntityId => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isException => boolean().withDefault(const Constant(false))();
  IntColumn get generationVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
