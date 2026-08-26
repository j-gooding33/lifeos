import 'package:drift/drift.dart';

/// §23.3. Every AI-sourced change lands here with `source = 'ai'` and is
/// undoable for 10 seconds (CLAUDE.md rule 8).
class ActivityLog extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get entityType => text().nullable()();
  TextColumn get entityId => text().nullable()();
  TextColumn get action => text().nullable()();
  TextColumn get payload => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
