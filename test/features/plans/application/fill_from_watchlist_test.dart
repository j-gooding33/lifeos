import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/features/plans/application/fill_from_watchlist.dart';

AppOccurrence _occurrence(String id, int day) =>
    AppOccurrence(id: id, planId: 'plan1', scheduledDate: CivilDate(2026, 9, day));

AppLibraryItem _item(String id, {String? title, DateTime? addedAt, int? runtimeMinutes}) {
  return AppLibraryItem(
    id: id,
    userId: 'u1',
    mediaType: MediaType.film,
    title: title ?? id,
    addedAt: addedAt,
    runtimeMinutes: runtimeMinutes,
  );
}

void main() {
  test('pairs occurrences to items earliest-date-first, capped at the shorter list', () {
    final occurrences = [_occurrence('o3', 10), _occurrence('o1', 1), _occurrence('o2', 5)];
    final items = [_item('a'), _item('b')];

    final pairs = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.added);

    expect(pairs, hasLength(2));
    expect(pairs[0].$1.id, 'o1');
    expect(pairs[1].$1.id, 'o2');
  });

  test('added order sorts by addedAt, oldest first', () {
    final occurrences = [_occurrence('o1', 1), _occurrence('o2', 2)];
    final items = [
      _item('newer', addedAt: DateTime(2026, 2, 15)),
      _item('older', addedAt: DateTime(2026, 1, 15)),
    ];

    final pairs = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.added);

    expect(pairs[0].$2.id, 'older');
    expect(pairs[1].$2.id, 'newer');
  });

  test('alphabetical order is case-insensitive and prefers sortTitle', () {
    final occurrences = [_occurrence('o1', 1), _occurrence('o2', 2)];
    final items = [_item('z', title: 'Zebra'), _item('a', title: 'apple')];

    final pairs = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.alphabetical);

    expect(pairs[0].$2.id, 'a');
    expect(pairs[1].$2.id, 'z');
  });

  test('shortest-first order sorts by runtime, with unknown runtimes last', () {
    final occurrences = [_occurrence('o1', 1), _occurrence('o2', 2), _occurrence('o3', 3)];
    final items = [_item('unknown'), _item('long', runtimeMinutes: 150), _item('short', runtimeMinutes: 90)];

    final pairs = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.shortestFirst);

    expect(pairs.map((p) => p.$2.id).toList(), ['short', 'long', 'unknown']);
  });

  test('shuffle order is deterministic given the same seeded Random', () {
    final occurrences = [_occurrence('o1', 1), _occurrence('o2', 2), _occurrence('o3', 3)];
    final items = [_item('a'), _item('b'), _item('c')];

    final first = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.shuffle, random: Random(42));
    final second = planWatchlistFill(emptyOccurrences: occurrences, unwatchedItems: items, order: WatchlistFillOrder.shuffle, random: Random(42));

    expect(first.map((p) => p.$2.id).toList(), second.map((p) => p.$2.id).toList());
  });

  test('no empty occurrences means nothing to fill', () {
    final pairs = planWatchlistFill(emptyOccurrences: const [], unwatchedItems: [_item('a')], order: WatchlistFillOrder.added);
    expect(pairs, isEmpty);
  });

  test('no unwatched items means nothing to fill', () {
    final pairs = planWatchlistFill(emptyOccurrences: [_occurrence('o1', 1)], unwatchedItems: const [], order: WatchlistFillOrder.added);
    expect(pairs, isEmpty);
  });
}
