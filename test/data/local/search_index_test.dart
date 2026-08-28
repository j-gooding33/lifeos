import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/database.dart';

/// §18.2: the `search_index` FTS5 table is maintained by triggers, not
/// application code — this exercises those triggers directly against a
/// real (in-memory) database, since `migration_test.dart` only proves the
/// migration runs without a SQL error, not that the trigger logic is
/// correct (right columns, right entity_type, survives an update/delete).
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<List<Map<String, Object?>>> searchRows() async {
    final rows = await db.customSelect('SELECT entity_type, entity_id, title, body, tags FROM search_index').get();
    return rows.map((r) => r.data).toList();
  }

  test('inserting a task indexes it', () async {
    await db
        .into(db.tasks)
        .insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Buy milk', notes: const Value('2%, not skimmed')));

    final rows = await searchRows();
    expect(rows, hasLength(1));
    expect(rows.single['entity_type'], 'task');
    expect(rows.single['entity_id'], 't1');
    expect(rows.single['title'], 'Buy milk');
    expect(rows.single['body'], '2%, not skimmed');
  });

  test('updating a task updates its indexed row instead of duplicating it', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Buy milk'));
    await (db.update(db.tasks)..where((t) => t.id.equals('t1'))).write(const TasksCompanion(title: Value('Buy oat milk')));

    final rows = await searchRows();
    expect(rows, hasLength(1));
    expect(rows.single['title'], 'Buy oat milk');
  });

  test('soft-deleting a task (deleted_at set via update) removes it from the index', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Buy milk'));
    await (db.update(db.tasks)..where((t) => t.id.equals('t1'))).write(TasksCompanion(deletedAt: Value(DateTime.now().millisecondsSinceEpoch)));

    expect(await searchRows(), isEmpty);
  });

  test('hard-deleting a row removes it from the index', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Buy milk'));
    await (db.delete(db.tasks)..where((t) => t.id.equals('t1'))).go();

    expect(await searchRows(), isEmpty);
  });

  test('a note is indexed on its plain-text projection, not the raw blocks JSON', () async {
    await db.into(db.notes).insert(
      NotesCompanion.insert(id: 'n1', userId: 'u1', blocks: '[]', title: const Value('Groceries'), plainText: const Value('Milk\nEggs')),
    );

    final rows = await searchRows();
    expect(rows.single['entity_type'], 'note');
    expect(rows.single['title'], 'Groceries');
    expect(rows.single['body'], 'Milk\nEggs');
  });

  test('a habit (a plan with kind = habit) is indexed as a plan, not separately', () async {
    await db.into(db.plans).insert(
      PlansCompanion.insert(id: 'p1', userId: 'u1', kind: const Value('habit'), title: 'Morning run', rule: '{}', anchorDate: '2026-08-28', startDate: '2026-08-28'),
    );

    final rows = await searchRows();
    expect(rows.single['entity_type'], 'plan');
    expect(rows.single['title'], 'Morning run');
  });

  test('library items are indexed under their own media_type, not one generic bucket', () async {
    await db.into(db.libraryItems).insert(
      LibraryItemsCompanion.insert(id: 'l1', userId: 'u1', mediaType: 'film', title: 'Arrival', overview: const Value('A linguist and a physicist...')),
    );
    await db.into(db.libraryItems).insert(
      LibraryItemsCompanion.insert(id: 'l2', userId: 'u1', mediaType: 'book', title: 'Dune'),
    );

    final rows = await searchRows();
    final types = rows.map((r) => r['entity_type']).toSet();
    expect(types, {'film', 'book'});
  });

  test('a journal entry is indexed with its date as title', () async {
    await db.into(db.journalEntries).insert(
      JournalEntriesCompanion.insert(id: 'j1', userId: 'u1', date: '2026-08-28', plainText: const Value('Good day.')),
    );

    final rows = await searchRows();
    expect(rows.single['entity_type'], 'journal');
    expect(rows.single['entity_id'], '2026-08-28');
    expect(rows.single['title'], '2026-08-28');
    expect(rows.single['body'], 'Good day.');
  });

  test('a link is indexed on its URL, titled from its own title or falling back to the URL', () async {
    await db.into(db.links).insert(LinksCompanion.insert(id: 'lk1', userId: 'u1', url: 'https://example.com/article'));
    await db.into(db.links).insert(LinksCompanion.insert(id: 'lk2', userId: 'u1', url: 'https://example.com/other', title: const Value('A saved page')));

    final rows = await searchRows();
    final byId = {for (final r in rows) r['entity_id']: r};
    expect(byId['lk1']!['title'], 'https://example.com/article');
    expect(byId['lk2']!['title'], 'A saved page');
    expect(byId['lk2']!['body'], 'https://example.com/other');
  });

  test('FTS5 MATCH actually finds an indexed row by a body substring token', () async {
    await db.into(db.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Something else', notes: const Value('Remember the quarterly report')));

    final rows = await db.customSelect("SELECT entity_id FROM search_index WHERE search_index MATCH 'quarterly'").get();
    expect(rows.map((r) => r.data['entity_id']), ['t1']);
  });
}
