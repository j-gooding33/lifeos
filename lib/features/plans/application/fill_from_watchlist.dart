import 'dart:math';

import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';

enum WatchlistFillOrder { added, alphabetical, shortestFirst, shuffle }

/// §16.5: "'Fill from watchlist' assigns the next N unwatched items to the
/// next N empty occurrences, in the user's chosen order (added,
/// alphabetical, shortest first, or shuffle)." Pure — no database, no
/// Flutter — so the pairing itself is directly testable; the caller does
/// the actual `linkOccurrenceToLibraryItem` writes.
///
/// [emptyOccurrences] should already be filtered to this plan's own
/// pending, unlinked occurrences — this only sorts and pairs them.
List<(AppOccurrence, AppLibraryItem)> planWatchlistFill({
  required List<AppOccurrence> emptyOccurrences,
  required List<AppLibraryItem> unwatchedItems,
  required WatchlistFillOrder order,
  Random? random,
}) {
  final sortedOccurrences = [...emptyOccurrences]..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  final orderedItems = _ordered(unwatchedItems, order, random ?? Random());
  final count = min(sortedOccurrences.length, orderedItems.length);
  return [for (var i = 0; i < count; i++) (sortedOccurrences[i], orderedItems[i])];
}

List<AppLibraryItem> _ordered(List<AppLibraryItem> items, WatchlistFillOrder order, Random random) {
  final copy = [...items];
  switch (order) {
    case WatchlistFillOrder.added:
      copy.sort((a, b) => a.addedAt.compareTo(b.addedAt));
    case WatchlistFillOrder.alphabetical:
      copy.sort((a, b) => (a.sortTitle ?? a.title).toLowerCase().compareTo((b.sortTitle ?? b.title).toLowerCase()));
    case WatchlistFillOrder.shortestFirst:
      // Books have no runtime/page-count field in this model yet — they
      // sort last (stable, by whatever order they arrived in) rather than
      // pretending to know their length.
      copy.sort((a, b) => (a.runtimeMinutes ?? 1 << 30).compareTo(b.runtimeMinutes ?? 1 << 30));
    case WatchlistFillOrder.shuffle:
      copy.shuffle(random);
  }
  return copy;
}
