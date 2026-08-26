import 'package:drift/drift.dart';

/// §23.3, §24. One row per table, tracking sync cursors.
class SyncState extends Table {
  // §23.3 names this column `table_name` — same Drift-reserved-identifier
  // collision as `Outbox.targetTable`; see that file's comment and
  // DECISIONS.md.
  TextColumn get targetTable => text().named('target_table')();
  IntColumn get lastPulledAt => integer().nullable()();
  IntColumn get lastPushedSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {targetTable};
}
