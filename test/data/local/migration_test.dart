import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/database.dart';

import 'generated_migrations/schema.dart';

/// §23.4: "Every migration ships with a test that opens a fixture database
/// at version N-1 and asserts the upgrade." There's only one version so
/// far, so this is the baseline case — it proves `onCreate` (all 30
/// tables, every partial index, the FTS5 virtual table) actually runs
/// clean, and gives the next migration something to extend rather than
/// invent from scratch. Regenerate `drift_schemas/` and
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

  test('a real AppDatabase opens against an in-memory executor', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    await db.close();
  });
}
