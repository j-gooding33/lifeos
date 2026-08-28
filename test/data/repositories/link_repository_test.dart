import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/link_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/link_repository.dart';
import 'package:life_os/data/repositories/models/app_link.dart';

AppLink _okLink(Result<AppLink, Failure> result) => result.when(ok: (l) => l, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late LinkRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LinkRepository(LinkDao(database));
  });

  tearDown(() => database.close());

  test('createLink then watchAll round-trips url, title and tags', () async {
    final created = await repository.createLink(userId: 'u1', url: 'https://example.com', title: 'Example', tags: const ['reading', 'tech']);
    final link = _okLink(created);

    final all = await repository.watchAll('u1').first;
    expect(all, hasLength(1));
    expect(all.single.url, 'https://example.com');
    expect(all.single.title, 'Example');
    expect(all.single.tags, ['reading', 'tech']);
    expect(link.displayTitle, 'Example');
  });

  test('a link with no title falls back to the URL as its display title', () async {
    final link = _okLink(await repository.createLink(userId: 'u1', url: 'https://example.com/page'));
    expect(link.title, isNull);
    expect(link.displayTitle, 'https://example.com/page');
  });

  test('updateLink can set a title and clear it again', () async {
    final link = _okLink(await repository.createLink(userId: 'u1', url: 'https://example.com'));
    await repository.updateLink(link.copyWith(title: 'Renamed'));
    expect((await repository.watchAll('u1').first).single.title, 'Renamed');

    await repository.updateLink(link.copyWith(clearTitle: true));
    expect((await repository.watchAll('u1').first).single.title, isNull);
  });

  test('deleteLink is a soft delete', () async {
    final link = _okLink(await repository.createLink(userId: 'u1', url: 'https://example.com'));
    await repository.deleteLink(link.id);
    expect(await repository.watchAll('u1').first, isEmpty);
  });

  test("watchAll only returns the given user's links", () async {
    await repository.createLink(userId: 'u1', url: 'https://mine.example.com');
    await repository.createLink(userId: 'u2', url: 'https://not-mine.example.com');
    final all = await repository.watchAll('u1').first;
    expect(all.map((l) => l.url), ['https://mine.example.com']);
  });
}
