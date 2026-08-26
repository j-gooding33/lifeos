import 'package:drift/drift.dart';

/// §23.3, §11.
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get deadline => text().nullable()();
  TextColumn get goalId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  RealColumn get sortIndex => real().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
