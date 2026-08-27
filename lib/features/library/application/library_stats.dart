import 'package:life_os/data/repositories/models/app_library_item.dart';

/// §16.6. Pure computation over already-loaded items — no Flutter, no
/// database access — so every rule here (what counts as "this year," how
/// ties in the genre count are broken) is unit-testable without a widget
/// or a fake clock plumbed through five layers.
class LibraryStats {
  const LibraryStats({
    required this.finishedThisYear,
    required this.finishedThisMonth,
    required this.averageRating,
    required this.topGenre,
    required this.totalRuntimeMinutes,
    required this.ratingDistribution,
  });

  final int finishedThisYear;
  final int finishedThisMonth;

  /// Null when nothing is rated yet — never `0`, which would misreport
  /// "rated zero stars on average."
  final double? averageRating;

  /// Null when no finished item has a genre on record.
  final String? topGenre;

  /// Null when runtime isn't a meaningful stat for this media type (books)
  /// — omitted from the UI entirely rather than shown as a fake `0`.
  final int? totalRuntimeMinutes;

  /// Keyed 1–5 (nearest whole star); always has all five keys, `0` counts
  /// included, so a caller never needs a default-value lookup.
  final Map<int, int> ratingDistribution;
}

LibraryStats computeLibraryStats(
  List<AppLibraryItem> items, {
  required DateTime now,
  bool includeRuntime = true,
}) {
  final finished = items.where((i) => i.status == LibraryItemStatus.done && i.finishedAt != null).toList();
  final finishedThisYear = finished.where((i) => i.finishedAt!.year == now.year).length;
  final finishedThisMonth = finished.where((i) => i.finishedAt!.year == now.year && i.finishedAt!.month == now.month).length;

  final rated = items.where((i) => i.isRated).toList();
  final averageRating = rated.isEmpty ? null : rated.map((i) => i.rating!).reduce((a, b) => a + b) / rated.length;

  final genreCounts = <String, int>{};
  for (final item in finished) {
    for (final genre in item.genres) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
  }
  String? topGenre;
  var topGenreCount = 0;
  for (final entry in genreCounts.entries) {
    if (entry.value > topGenreCount) {
      topGenre = entry.key;
      topGenreCount = entry.value;
    }
  }

  // §16.6's own worked example ("94 hours of film this year") scopes the
  // runtime total to the current year, same window as finishedThisYear.
  final totalRuntimeMinutes = includeRuntime
      ? finished.where((i) => i.finishedAt!.year == now.year).fold<int>(0, (sum, i) => sum + (i.runtimeMinutes ?? 0))
      : null;

  final ratingDistribution = {for (var star = 1; star <= 5; star++) star: 0};
  for (final item in rated) {
    final bucket = item.rating!.round().clamp(1, 5);
    ratingDistribution[bucket] = ratingDistribution[bucket]! + 1;
  }

  return LibraryStats(
    finishedThisYear: finishedThisYear,
    finishedThisMonth: finishedThisMonth,
    averageRating: averageRating,
    topGenre: topGenre,
    totalRuntimeMinutes: totalRuntimeMinutes,
    ratingDistribution: ratingDistribution,
  );
}
