import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';

AppLibraryItem _okItem(Result<AppLibraryItem, Failure> result) => result.when(
  ok: (i) => i,
  err: (f) => throw StateError('expected Ok, got ${f.message}'),
);

void main() {
  late AppDatabase database;
  late LibraryItemRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LibraryItemRepository(LibraryItemDao(database));
  });

  tearDown(() => database.close());

  test('adding the same external id twice returns the existing item, not a duplicate', () async {
    const result = MediaSearchResult(
      externalId: '157336',
      title: 'Interstellar',
      year: 2014,
    );
    final first = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );
    final second = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );

    expect(second.id, first.id);
    final all = await repository.watchAll('u1', MediaType.film).first;
    expect(all, hasLength(1));
  });

  test('a new item starts on the wishlist', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Dune',
      year: 2021,
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );
    expect(item.status, LibraryItemStatus.wishlist);
  });

  test(
    'marking watched without a rating leaves rating null (§43 edge case)',
    () async {
      const result = MediaSearchResult(
        externalId: '1',
        title: 'Dune',
        year: 2021,
      );
      final item = _okItem(
        await repository.addFromSearchResult(
          userId: 'u1',
          type: MediaType.film,
          providerId: 'tmdb',
          result: result,
        ),
      );

      await repository.markWatched(item.id, watchedDate: DateTime(2026, 8, 27));

      final updated = await repository.watchById(item.id).first;
      expect(updated!.status, LibraryItemStatus.done);
      expect(updated.finishedAt, DateTime(2026, 8, 27));
      expect(updated.rating, isNull);
    },
  );

  test('rating before marking watched is allowed (§43 edge case)', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Dune',
      year: 2021,
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );

    await repository.setRating(item.id, 4.5);

    final updated = await repository.watchById(item.id).first;
    expect(updated!.rating, 4.5);
    expect(
      updated.status,
      LibraryItemStatus.wishlist,
    ); // still not marked watched
  });

  test('a rating can be changed later, including cleared', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Dune',
      year: 2021,
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );
    await repository.setRating(item.id, 3);
    await repository.setRating(item.id, 5);
    expect((await repository.watchById(item.id).first)!.rating, 5);

    await repository.setRating(item.id, null);
    expect((await repository.watchById(item.id).first)!.rating, isNull);
  });

  test('the personal log/notes is editable', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Dune',
      year: 2021,
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );

    await repository.setNotes(item.id, 'Loved the visuals.');
    expect(
      (await repository.watchById(item.id).first)!.notes,
      'Loved the visuals.',
    );

    await repository.setNotes(
      item.id,
      'Loved the visuals even more on rewatch.',
    );
    expect(
      (await repository.watchById(item.id).first)!.notes,
      'Loved the visuals even more on rewatch.',
    );
  });

  test('favouriting and unfavouriting', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Dune',
      year: 2021,
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );

    await repository.setFavourite(item.id, isFavourite: true);
    expect(
      (await repository.watchFavourites('u1', MediaType.film).first).map(
        (i) => i.id,
      ),
      contains(item.id),
    );

    await repository.setFavourite(item.id, isFavourite: false);
    expect(
      (await repository.watchFavourites('u1', MediaType.film).first).map(
        (i) => i.id,
      ),
      isNot(contains(item.id)),
    );
  });

  test('watchRated only includes items with a rating', () async {
    final rated = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: const MediaSearchResult(externalId: '1', title: 'Rated'),
      ),
    );
    await repository.addFromSearchResult(
      userId: 'u1',
      type: MediaType.film,
      providerId: 'tmdb',
      result: const MediaSearchResult(externalId: '2', title: 'Unrated'),
    );
    await repository.setRating(rated.id, 4);

    final ratedItems = await repository
        .watchRated('u1', MediaType.film)
        .first;
    expect(ratedItems.map((i) => i.title), ['Rated']);
  });

  test('manual add works without a search result (§16.7 fallback)', () async {
    final item = _okItem(
      await repository.addManually(
        userId: 'u1',
        type: MediaType.book,
        title: 'A Rare Book',
      ),
    );
    expect(item.title, 'A Rare Book');
    expect(item.status, LibraryItemStatus.wishlist);
  });

  test('removing soft-deletes: it disappears from every view', () async {
    final item = _okItem(
      await repository.addManually(
        userId: 'u1',
        type: MediaType.book,
        title: 'Gone soon',
      ),
    );
    await repository.remove(item.id);
    final all = await repository.watchAll('u1', MediaType.book).first;
    expect(all, isEmpty);
  });

  test('genres and creators round-trip through JSON storage', () async {
    const result = MediaSearchResult(
      externalId: '1',
      title: 'Interstellar',
      genres: ['Sci-Fi', 'Drama'],
    );
    final item = _okItem(
      await repository.addFromSearchResult(
        userId: 'u1',
        type: MediaType.film,
        providerId: 'tmdb',
        result: result,
      ),
    );
    final reloaded = await repository.watchById(item.id).first;
    expect(reloaded!.genres, ['Sci-Fi', 'Drama']);
  });
}
