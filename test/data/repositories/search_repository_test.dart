import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/search_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/search_repository.dart';

void main() {
  late AppDatabase database;
  late SearchRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SearchRepository(SearchDao(database));
  });

  tearDown(() => database.close());

  test('an empty or punctuation-only query returns no groups without hitting the database', () async {
    expect(await repository.search(''), isEmpty);
    expect(await repository.search('   '), isEmpty);
    expect(await repository.search('***'), isEmpty);
  });

  test('a query finds a task by a word in its title', () async {
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Buy groceries'));

    final groups = await repository.search('groceries');
    expect(groups, hasLength(1));
    expect(groups.single.entityType, 'task');
    expect(groups.single.results.single.title, 'Buy groceries');
  });

  test('a prefix matches a longer word (§18.1: prefix matching)', () async {
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Quarterly report'));

    final groups = await repository.search('quart');
    expect(groups.single.results.single.title, 'Quarterly report');
  });

  test('results from different entity types land in separate groups', () async {
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Project kickoff'));
    await database.into(database.notes).insert(NotesCompanion.insert(id: 'n1', userId: 'u1', blocks: '[]', plainText: const Value('Project kickoff notes')));

    final groups = await repository.search('project');
    final types = groups.map((g) => g.entityType).toSet();
    expect(types, {'task', 'note'});
  });

  test('a title match ranks above a body-only match for the same term', () async {
    await database
        .into(database.tasks)
        .insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Something unrelated', notes: const Value('mentions widget once')));
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't2', userId: 'u1', title: 'Fix the widget'));

    final groups = await repository.search('widget');
    final order = groups.single.results.map((r) => r.entityId).toList();
    expect(order.first, 't2');
  });

  test('a snippet is truncated with an ellipsis past 120 characters', () async {
    final longNote = 'x' * 200;
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Long task', notes: Value(longNote)));

    final groups = await repository.search('long');
    final snippet = groups.single.results.single.snippet;
    expect(snippet.length, 121);
    expect(snippet.endsWith('…'), isTrue);
  });

  test('punctuation in the query is stripped rather than breaking FTS5 syntax', () async {
    await database.into(database.tasks).insert(TasksCompanion.insert(id: 't1', userId: 'u1', title: 'Call mum'));

    // A raw quote or colon would otherwise be interpreted as FTS5 syntax
    // and throw — this should just search for "mum".
    final groups = await repository.search('mum"::*');
    expect(groups.single.results.single.entityId, 't1');
  });
}
