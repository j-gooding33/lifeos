/// The `search_index` backfill — (re)populates it from every source table's
/// current, non-deleted rows. Shared by `v3_search_triggers.dart` (the
/// one-time backfill run at migration time) and `SearchDao.rebuild` (the
/// on-demand "Rebuild search index" in Settings → Data, §18.2's own
/// "recovery" escape hatch), so the two never drift apart.
const searchIndexBackfillStatements = [
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'task', id, title, COALESCE(notes, ''), '' FROM tasks WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'note', id, COALESCE(title, ''), COALESCE(plain_text, ''), '' FROM notes WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'plan', id, title, COALESCE(notes, ''), '' FROM plans WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'project', id, title, COALESCE(description, ''), '' FROM projects WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'goal', id, title, COALESCE(description, ''), '' FROM goals WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'event', id, title, COALESCE(notes, ''), '' FROM events WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'journal', date, date, COALESCE(plain_text, ''), '' FROM journal_entries WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT media_type, id, title, COALESCE(overview, ''), '' FROM library_items WHERE deleted_at IS NULL;
  ''',
  '''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'link', id, COALESCE(title, url), url, COALESCE(tags, '') FROM links WHERE deleted_at IS NULL;
  ''',
];
