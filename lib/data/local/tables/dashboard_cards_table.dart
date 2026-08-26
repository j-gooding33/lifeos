import 'package:drift/drift.dart';

/// §23.3, §5.3. One row per card on the Home dashboard.
class DashboardCards extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  IntColumn get position => integer()();
  BoolColumn get visible => boolean().withDefault(const Constant(true))();
  TextColumn get size => text().withDefault(const Constant('medium'))();
  TextColumn get config => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
