import 'package:drift/drift.dart';

/// The §23.3 indexes that need a partial `WHERE` clause, which Drift's
/// table-level `@TableIndex` annotation can't express — issued as raw SQL
/// once on database creation instead. Also creates the `search_index`
/// FTS5 virtual table (§18, needed from M14): Drift's typed FTS5 table
/// support is real but its API surface shifts across versions, and this
/// table isn't touched by any code before M14, so raw SQL here is the
/// lower-risk choice for now. See DECISIONS.md.
Future<void> createV1IndexesAndFts(Migrator m) async {
  final db = m.database;
  await db.customStatement(
    'CREATE INDEX idx_tasks_due ON tasks(user_id, due_date) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_tasks_project ON tasks(project_id) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_tasks_open ON tasks(user_id, completed_at) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_occ_unique ON plan_occurrences(plan_id, scheduled_date, generation_version) '
    'WHERE is_exception = 0 AND deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_occ_date ON plan_occurrences(user_id, scheduled_date) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_occ_plan ON plan_occurrences(plan_id, scheduled_date DESC);',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_contrib_dedupe ON goal_contributions(goal_id, source_type, source_id);',
  );
  await db.customStatement('CREATE INDEX idx_events_range ON events(user_id, start_at);');
  await db.customStatement(
    'CREATE INDEX idx_reminders_fire ON reminders(user_id, fire_at) WHERE cancelled_at IS NULL;',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_lib_external ON library_items(user_id, provider_id, external_id) '
    'WHERE external_id IS NOT NULL AND deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_journal_date ON journal_entries(user_id, date) WHERE deleted_at IS NULL;',
  );
  await db.customStatement('''
    CREATE VIRTUAL TABLE search_index USING fts5(
      entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
      tokenize='unicode61 remove_diacritics 2'
    );
  ''');
}
