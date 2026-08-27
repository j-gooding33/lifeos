import 'package:drift/drift.dart';

/// M8's schema addition: TV episodes, top lists, and the School system.
/// Same reason as `v1_indexes.dart` — the partial/composite `WHERE`
/// clauses these need aren't expressible via Drift's `@TableIndex`.
Future<void> createV2Indexes(Migrator m) async {
  final db = m.database;
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_tv_episode_unique ON tv_episodes(library_item_id, season_number, episode_number) '
    'WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_top_list_rank_unique ON top_list_items(user_id, media_type, rank);',
  );
  await db.customStatement(
    'CREATE UNIQUE INDEX idx_top_list_item_unique ON top_list_items(user_id, media_type, library_item_id);',
  );
  await db.customStatement(
    'CREATE INDEX idx_school_lessons_lookup ON school_lessons(user_id, week_label, weekday) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_school_terms_range ON school_terms(user_id, start_date, end_date) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_school_closures_range ON school_closures(user_id, start_date, end_date) WHERE deleted_at IS NULL;',
  );
  await db.customStatement(
    'CREATE INDEX idx_school_events_date ON school_events(user_id, date) WHERE deleted_at IS NULL;',
  );
}
