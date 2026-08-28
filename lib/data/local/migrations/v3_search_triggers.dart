import 'package:drift/drift.dart';

/// §18.2: "maintained by triggers on every searchable table." `search_index`
/// (the FTS5 virtual table) has existed since v1 but nothing wrote to it —
/// this is that wiring, plus a one-time backfill so existing rows become
/// searchable immediately rather than only from the next edit onward. Kept
/// entirely in triggers rather than touching each repository's save method:
/// zero risk to already-shipped, already-tested write paths, and every
/// entity stays in sync automatically, including rows written by future
/// code nobody remembers to thread search-indexing into.
///
/// Each table gets three triggers (AFTER INSERT / AFTER UPDATE / AFTER
/// DELETE), spelled out explicitly per table rather than through a
/// generic helper — a helper that has to paper over "NEW doesn't exist in
/// a DELETE trigger, OLD doesn't exist in an INSERT trigger" is more
/// error-prone than writing each one out. SQLite fires the UPDATE
/// trigger, not INSERT, for the `DO UPDATE` branch of `INSERT ... ON
/// CONFLICT` (Drift's `insertOnConflictUpdate`, used by every
/// repository's `_save`), so the insert/update pair covers upserts
/// correctly without a third case.
Future<void> createV3SearchTriggers(Migrator m) async {
  final db = m.database;

  // tasks
  await db.customStatement('''
    CREATE TRIGGER trg_tasks_search_ai AFTER INSERT ON tasks BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'task', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_tasks_search_au AFTER UPDATE ON tasks BEGIN
      DELETE FROM search_index WHERE entity_type = 'task' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'task', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_tasks_search_ad AFTER DELETE ON tasks BEGIN
      DELETE FROM search_index WHERE entity_type = 'task' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'task', id, title, COALESCE(notes, ''), '' FROM tasks WHERE deleted_at IS NULL;
  ''');

  // notes
  await db.customStatement('''
    CREATE TRIGGER trg_notes_search_ai AFTER INSERT ON notes BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'note', NEW.id, COALESCE(NEW.title, ''), COALESCE(NEW.plain_text, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_notes_search_au AFTER UPDATE ON notes BEGIN
      DELETE FROM search_index WHERE entity_type = 'note' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'note', NEW.id, COALESCE(NEW.title, ''), COALESCE(NEW.plain_text, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_notes_search_ad AFTER DELETE ON notes BEGIN
      DELETE FROM search_index WHERE entity_type = 'note' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'note', id, COALESCE(title, ''), COALESCE(plain_text, ''), '' FROM notes WHERE deleted_at IS NULL;
  ''');

  // plans (habits included — kind = 'habit' is still a plan row)
  await db.customStatement('''
    CREATE TRIGGER trg_plans_search_ai AFTER INSERT ON plans BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'plan', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_plans_search_au AFTER UPDATE ON plans BEGIN
      DELETE FROM search_index WHERE entity_type = 'plan' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'plan', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_plans_search_ad AFTER DELETE ON plans BEGIN
      DELETE FROM search_index WHERE entity_type = 'plan' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'plan', id, title, COALESCE(notes, ''), '' FROM plans WHERE deleted_at IS NULL;
  ''');

  // projects
  await db.customStatement('''
    CREATE TRIGGER trg_projects_search_ai AFTER INSERT ON projects BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'project', NEW.id, NEW.title, COALESCE(NEW.description, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_projects_search_au AFTER UPDATE ON projects BEGIN
      DELETE FROM search_index WHERE entity_type = 'project' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'project', NEW.id, NEW.title, COALESCE(NEW.description, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_projects_search_ad AFTER DELETE ON projects BEGIN
      DELETE FROM search_index WHERE entity_type = 'project' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'project', id, title, COALESCE(description, ''), '' FROM projects WHERE deleted_at IS NULL;
  ''');

  // goals
  await db.customStatement('''
    CREATE TRIGGER trg_goals_search_ai AFTER INSERT ON goals BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'goal', NEW.id, NEW.title, COALESCE(NEW.description, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_goals_search_au AFTER UPDATE ON goals BEGIN
      DELETE FROM search_index WHERE entity_type = 'goal' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'goal', NEW.id, NEW.title, COALESCE(NEW.description, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_goals_search_ad AFTER DELETE ON goals BEGIN
      DELETE FROM search_index WHERE entity_type = 'goal' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'goal', id, title, COALESCE(description, ''), '' FROM goals WHERE deleted_at IS NULL;
  ''');

  // events
  await db.customStatement('''
    CREATE TRIGGER trg_events_search_ai AFTER INSERT ON events BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'event', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_events_search_au AFTER UPDATE ON events BEGIN
      DELETE FROM search_index WHERE entity_type = 'event' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'event', NEW.id, NEW.title, COALESCE(NEW.notes, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_events_search_ad AFTER DELETE ON events BEGIN
      DELETE FROM search_index WHERE entity_type = 'event' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'event', id, title, COALESCE(notes, ''), '' FROM events WHERE deleted_at IS NULL;
  ''');

  // journal_entries — entity_id is the entry's date, not its row id: the
  // only route that opens a journal entry (/journal/:date) is date-keyed,
  // and (user_id, date) is already unique (idx_journal_date), so the date
  // is a stable, sufficient identifier here.
  await db.customStatement('''
    CREATE TRIGGER trg_journal_search_ai AFTER INSERT ON journal_entries BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'journal', NEW.date, NEW.date, COALESCE(NEW.plain_text, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_journal_search_au AFTER UPDATE ON journal_entries BEGIN
      DELETE FROM search_index WHERE entity_type = 'journal' AND entity_id = OLD.date;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'journal', NEW.date, NEW.date, COALESCE(NEW.plain_text, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_journal_search_ad AFTER DELETE ON journal_entries BEGIN
      DELETE FROM search_index WHERE entity_type = 'journal' AND entity_id = OLD.date;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'journal', date, date, COALESCE(plain_text, ''), '' FROM journal_entries WHERE deleted_at IS NULL;
  ''');

  // library_items — entity_type is the row's own media_type (film/tv/book),
  // so results group by that instead of one generic "library" bucket.
  await db.customStatement('''
    CREATE TRIGGER trg_library_items_search_ai AFTER INSERT ON library_items BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT NEW.media_type, NEW.id, NEW.title, COALESCE(NEW.overview, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_library_items_search_au AFTER UPDATE ON library_items BEGIN
      DELETE FROM search_index WHERE entity_type = OLD.media_type AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT NEW.media_type, NEW.id, NEW.title, COALESCE(NEW.overview, ''), ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_library_items_search_ad AFTER DELETE ON library_items BEGIN
      DELETE FROM search_index WHERE entity_type = OLD.media_type AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT media_type, id, title, COALESCE(overview, ''), '' FROM library_items WHERE deleted_at IS NULL;
  ''');

  // links
  await db.customStatement('''
    CREATE TRIGGER trg_links_search_ai AFTER INSERT ON links BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'link', NEW.id, COALESCE(NEW.title, NEW.url), NEW.url, COALESCE(NEW.tags, '')
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_links_search_au AFTER UPDATE ON links BEGIN
      DELETE FROM search_index WHERE entity_type = 'link' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'link', NEW.id, COALESCE(NEW.title, NEW.url), NEW.url, COALESCE(NEW.tags, '')
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_links_search_ad AFTER DELETE ON links BEGIN
      DELETE FROM search_index WHERE entity_type = 'link' AND entity_id = OLD.id;
    END;
  ''');
  await db.customStatement('''
    INSERT INTO search_index(entity_type, entity_id, title, body, tags)
    SELECT 'link', id, COALESCE(title, url), url, COALESCE(tags, '') FROM links WHERE deleted_at IS NULL;
  ''');
}
