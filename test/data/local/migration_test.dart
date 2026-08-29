import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/database.dart';

import 'generated_migrations/schema.dart';

/// §23.4: "Every migration ships with a test that opens a fixture database
/// at version N-1 and asserts the upgrade." v1's own creation is the
/// baseline case, proving `onCreate` runs clean; each later version adds
/// its own "vN schema creates cleanly" plus a "vN-1 to vN migrates
/// cleanly" upgrade test. Regenerate `drift_schemas/` and
/// `generated_migrations/` with `dart run drift_dev schema dump` /
/// `schema generate` whenever `schemaVersion` bumps.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v1 schema creates cleanly', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase.forTesting(connection.executor);
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('v2 schema creates cleanly', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase.forTesting(connection.executor);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v3 schema creates cleanly', () async {
    final connection = await verifier.startAt(3);
    final db = AppDatabase.forTesting(connection.executor);
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });

  test('v4 schema creates cleanly', () async {
    final connection = await verifier.startAt(4);
    final db = AppDatabase.forTesting(connection.executor);
    await verifier.migrateAndValidate(db, 4);
    await db.close();
  });

  test('v5 schema creates cleanly', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.forTesting(connection.executor);
    await verifier.migrateAndValidate(db, 5);
    await db.close();
  });

  test(
    'v1 to v2 migrates cleanly (M8: TV episodes, top lists, School)',
    () async {
      final connection = await verifier.startAt(1);
      final db = AppDatabase.forTesting(connection.executor);
      await verifier.migrateAndValidate(db, 2);
      await db.close();
    },
  );

  test(
    'v2 to v3 migrates cleanly (Links table, search_index triggers)',
    () async {
      // A real v2-era database always already has `search_index` — it's
      // created via raw SQL in v1's onCreate (§18.2, not a Drift-typed
      // table, so `schema dump`/the v1/v2 fixtures below can't see it).
      // Recreate that real precondition before exercising the v2->v3
      // upgrade, which is the first migration to assume it's there.
      final schema = await verifier.schemaAt(2);
      schema.rawDatabase.execute('''
        CREATE VIRTUAL TABLE search_index USING fts5(
          entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
          tokenize='unicode61 remove_diacritics 2'
        );
      ''');
      final db = AppDatabase.forTesting(schema.newConnection().executor);
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    },
  );

  test(
    'v3 to v4 migrates cleanly (Documents table, search_index triggers)',
    () async {
      // Same real-world precondition as the v2->v3 case above: a v3-era
      // database already has `search_index` (raw SQL, invisible to `schema
      // dump`), and v4's own triggers on `documents` reference it too.
      final schema = await verifier.schemaAt(3);
      schema.rawDatabase.execute('''
        CREATE VIRTUAL TABLE search_index USING fts5(
          entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
          tokenize='unicode61 remove_diacritics 2'
        );
      ''');
      final db = AppDatabase.forTesting(schema.newConnection().executor);
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    },
  );

  test(
    'v4 to v5 migrates cleanly (DocumentLinks table)',
    () async {
      // A plain typed table with no raw-SQL preconditions (unlike v3/v4) —
      // no fixture setup needed beyond the standard v4 starting point.
      final connection = await verifier.startAt(4);
      final db = AppDatabase.forTesting(connection.executor);
      await verifier.migrateAndValidate(db, 5);
      await db.close();
    },
  );

  test(
    'v3 to v5 migrates cleanly in one jump (documents + document_links together)',
    () async {
      final schema = await verifier.schemaAt(3);
      schema.rawDatabase.execute('''
        CREATE VIRTUAL TABLE search_index USING fts5(
          entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
          tokenize='unicode61 remove_diacritics 2'
        );
      ''');
      final db = AppDatabase.forTesting(schema.newConnection().executor);
      await verifier.migrateAndValidate(db, 5);
      await db.close();
    },
  );

  test(
    'v2 to v4 migrates cleanly in one jump (the from < 3 && to >= 3 guard, plus v4)',
    () async {
      // The exact scenario DECISIONS.md's "real bug" note warns about: a
      // multi-version jump must not let an intermediate version's guard
      // misfire. Also proves the v3 block's search_index backfill runs
      // before v4's CREATE TABLE documents, not after (see
      // documentSearchIndexBackfillStatement's own doc comment).
      final schema = await verifier.schemaAt(2);
      schema.rawDatabase.execute('''
        CREATE VIRTUAL TABLE search_index USING fts5(
          entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags,
          tokenize='unicode61 remove_diacritics 2'
        );
      ''');
      final db = AppDatabase.forTesting(schema.newConnection().executor);
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    },
  );

  test('a real AppDatabase opens against an in-memory executor', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    await db.close();
  });
}
