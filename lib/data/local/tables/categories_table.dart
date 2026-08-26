import 'package:drift/drift.dart';

/// §23.3. Shared across domains (`domain` is `task | expense | plan`)
/// rather than one table per domain.
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get domain => text()();
  TextColumn get name => text()();
  TextColumn get colour => text().nullable()();
  TextColumn get icon => text().nullable()();
  RealColumn get sortIndex => real().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
