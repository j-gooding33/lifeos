import 'package:drift/drift.dart';

/// §23.3. Key/value settings store — avoids a schema migration per setting.
class Preferences extends Table {
  TextColumn get userId => text()();
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {userId, key};
}
