import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/data/local/daos/top_list_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/top_list_repository.dart';

void main() {
  late AppDatabase database;
  late TopListRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TopListRepository(TopListDao(database));
  });

  tearDown(() => database.close());

  test('adding films assigns increasing ranks', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.film, 'film2');

    final list = await repository.watch('u1', LibraryMediaType.film).first;
    expect(list.map((e) => (e.libraryItemId, e.rank)), [
      ('film1', 1),
      ('film2', 2),
    ]);
  });

  test('films cap at 5, books cap at 3 (Part 42)', () async {
    for (var i = 0; i < 5; i++) {
      await repository.add('u1', LibraryMediaType.film, 'film$i');
    }
    final sixthResult = await repository.add(
      'u1',
      LibraryMediaType.film,
      'film5',
    );
    sixthResult.when(
      ok: (_) => fail('expected a full-list Err'),
      err: (failure) => expect(failure, isA<TopListFullFailure>()),
    );

    for (var i = 0; i < 3; i++) {
      await repository.add('u1', LibraryMediaType.book, 'book$i');
    }
    final fourthResult = await repository.add(
      'u1',
      LibraryMediaType.book,
      'book3',
    );
    fourthResult.when(
      ok: (_) => fail('expected a full-list Err'),
      err: (f) => expect(f, isA<TopListFullFailure>()),
    );
  });

  test('adding the same item twice is a no-op, not a duplicate rank', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.film, 'film1');
    final list = await repository.watch('u1', LibraryMediaType.film).first;
    expect(list, hasLength(1));
  });

  test('removing an item closes the gap so ranks stay contiguous', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.film, 'film2');
    await repository.add('u1', LibraryMediaType.film, 'film3');

    await repository.remove('u1', LibraryMediaType.film, 'film2');

    final list = await repository.watch('u1', LibraryMediaType.film).first;
    expect(list.map((e) => (e.libraryItemId, e.rank)), [
      ('film1', 1),
      ('film3', 2),
    ]);
  });

  test('replace swaps an item in place, keeping its rank', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.film, 'film2');

    await repository.replace(
      'u1',
      LibraryMediaType.film,
      'film1',
      'film1-replacement',
    );

    final list = await repository.watch('u1', LibraryMediaType.film).first;
    expect(list.map((e) => (e.libraryItemId, e.rank)), [
      ('film1-replacement', 1),
      ('film2', 2),
    ]);
  });

  test('reorder rewrites ranks to match the given order', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.film, 'film2');
    await repository.add('u1', LibraryMediaType.film, 'film3');

    await repository.reorder('u1', LibraryMediaType.film, [
      'film3',
      'film1',
      'film2',
    ]);

    final list = await repository.watch('u1', LibraryMediaType.film).first;
    expect(list.map((e) => (e.libraryItemId, e.rank)), [
      ('film3', 1),
      ('film1', 2),
      ('film2', 3),
    ]);
  });

  test('film and book top lists are independent of each other', () async {
    await repository.add('u1', LibraryMediaType.film, 'film1');
    await repository.add('u1', LibraryMediaType.book, 'book1');

    expect(
      await repository.watch('u1', LibraryMediaType.film).first,
      hasLength(1),
    );
    expect(
      await repository.watch('u1', LibraryMediaType.book).first,
      hasLength(1),
    );
    expect(await repository.watch('u1', LibraryMediaType.tv).first, isEmpty);
  });
}
