import 'package:drift/drift.dart';

/// §23.3, §17.3. A saved URL bookmark — the one table this session needed
/// to add outright rather than wire up an M4-era column (see DECISIONS.md).
/// Open Graph enrichment (favicon/title auto-fill) isn't built; `title`
/// and `faviconUrl` are set manually or left null.
class Links extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  TextColumn get faviconUrl => text().nullable()();
  TextColumn get tags => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
