import 'package:drift/drift.dart';
import 'package:life_os/data/local/search_index_sql.dart';

/// §17.3, §18.2. `Documents` joins the searchable set (title only — there's
/// no body text to index, just the file itself). Mirrors the exact
/// AFTER INSERT/UPDATE/DELETE shape `v3_search_triggers.dart` uses for
/// every other table, kept in its own file since it's a schema bump of
/// its own rather than something that could ride along with v3.
Future<void> createV4DocumentSearchTriggers(Migrator m) async {
  final db = m.database;

  await db.customStatement('''
    CREATE TRIGGER trg_documents_search_ai AFTER INSERT ON documents BEGIN
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'document', NEW.id, NEW.title, '', ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_documents_search_au AFTER UPDATE ON documents BEGIN
      DELETE FROM search_index WHERE entity_type = 'document' AND entity_id = OLD.id;
      INSERT INTO search_index(entity_type, entity_id, title, body, tags)
      SELECT 'document', NEW.id, NEW.title, '', ''
      WHERE NEW.deleted_at IS NULL;
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER trg_documents_search_ad AFTER DELETE ON documents BEGIN
      DELETE FROM search_index WHERE entity_type = 'document' AND entity_id = OLD.id;
    END;
  ''');

  await db.customStatement(documentSearchIndexBackfillStatement);
}
