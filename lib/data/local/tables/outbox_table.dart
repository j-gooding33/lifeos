import 'package:drift/drift.dart';

/// §23.3, §24. The sync outbox — every local write that needs pushing
/// gets queued here (M19), not pushed inline with the write.
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  // §23.3 names this column `table_name`, but that SQL name round-trips to
  // a Dart `tableName` getter in Drift's own schema-snapshot codegen
  // (used for migration testing), which collides with `Table`'s reserved
  // `tableName` override point — renaming only the Dart-side getter isn't
  // enough since the collision is name-based on the *SQL* column. Deviates
  // from the spec's literal column name; see DECISIONS.md.
  TextColumn get targetTable => text().named('target_table')();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get payload => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}
