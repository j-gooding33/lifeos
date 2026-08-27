import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/features/library/application/library_stats.dart';

AppLibraryItem _item({
  required String id,
  LibraryItemStatus status = LibraryItemStatus.done,
  DateTime? finishedAt,
  double? rating,
  List<String> genres = const [],
  int? runtimeMinutes,
}) {
  return AppLibraryItem(
    id: id,
    userId: 'u1',
    mediaType: MediaType.film,
    title: id,
    status: status,
    finishedAt: finishedAt,
    rating: rating,
    genres: genres,
    runtimeMinutes: runtimeMinutes,
  );
}

void main() {
  final now = DateTime(2026, 8, 27);

  test('counts only done items with a finishedAt date this year/month', () {
    final stats = computeLibraryStats([
      _item(id: 'a', finishedAt: DateTime(2026, 8)), // this month
      _item(id: 'b', finishedAt: DateTime(2026)), // this year, not this month
      _item(id: 'c', finishedAt: DateTime(2025, 12, 31)), // last year
      _item(id: 'd', status: LibraryItemStatus.wishlist, finishedAt: DateTime(2026, 8, 2)), // not done
      _item(id: 'e'), // done but no finishedAt
    ], now: now);

    expect(stats.finishedThisYear, 2);
    expect(stats.finishedThisMonth, 1);
  });

  test('averageRating is null with nothing rated, never zero', () {
    final stats = computeLibraryStats([_item(id: 'a'), _item(id: 'b')], now: now);
    expect(stats.averageRating, isNull);
  });

  test('averageRating averages every rated item regardless of watched status', () {
    final stats = computeLibraryStats([
      _item(id: 'a', rating: 4),
      _item(id: 'b', rating: 2, status: LibraryItemStatus.wishlist),
    ], now: now);
    expect(stats.averageRating, 3.0);
  });

  test('topGenre is the most frequent genre among finished items, ties broken by first-seen', () {
    final stats = computeLibraryStats([
      _item(id: 'a', finishedAt: now, genres: ['Drama', 'Thriller']),
      _item(id: 'b', finishedAt: now, genres: ['Drama']),
      _item(id: 'c', finishedAt: now, genres: ['Comedy']),
    ], now: now);
    expect(stats.topGenre, 'Drama');
  });

  test('topGenre is null when no finished item has a genre', () {
    final stats = computeLibraryStats([_item(id: 'a', finishedAt: now)], now: now);
    expect(stats.topGenre, isNull);
  });

  test("totalRuntimeMinutes sums only this year's finished items, and is null when includeRuntime is false", () {
    final items = [
      _item(id: 'a', finishedAt: now, runtimeMinutes: 100),
      _item(id: 'b', finishedAt: now, runtimeMinutes: 50),
      _item(id: 'c', finishedAt: DateTime(2025, 6), runtimeMinutes: 500), // last year
      _item(id: 'd', status: LibraryItemStatus.wishlist, runtimeMinutes: 999),
    ];
    expect(computeLibraryStats(items, now: now).totalRuntimeMinutes, 150);
    expect(computeLibraryStats(items, now: now, includeRuntime: false).totalRuntimeMinutes, isNull);
  });

  test('ratingDistribution always has all five buckets, half-stars rounded to the nearest', () {
    final stats = computeLibraryStats([
      _item(id: 'a', rating: 4.5), // rounds to 5 (round-half-up)
      _item(id: 'b', rating: 4.4), // rounds to 4
      _item(id: 'c', rating: 1),
    ], now: now);
    expect(stats.ratingDistribution, {1: 1, 2: 0, 3: 0, 4: 1, 5: 1});
  });

  test('empty input produces zeroed stats, not a crash', () {
    final stats = computeLibraryStats(const [], now: now);
    expect(stats.finishedThisYear, 0);
    expect(stats.finishedThisMonth, 0);
    expect(stats.averageRating, isNull);
    expect(stats.topGenre, isNull);
    expect(stats.totalRuntimeMinutes, 0);
    expect(stats.ratingDistribution.values.every((c) => c == 0), isTrue);
  });
}
