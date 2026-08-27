import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/top_list_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:uuid/uuid.dart';

/// One entry in a Top-N list: which item, and at what rank. The UI joins
/// this with `LibraryItemRepository` to render title/poster — this
/// repository only owns the ranking.
class TopListEntry {
  const TopListEntry({
    required this.id,
    required this.libraryItemId,
    required this.rank,
  });

  final String id;
  final String libraryItemId;
  final int rank;
}

/// M8 Parts 7/16/24. "My Top 5 Films", "My Top 5 TV Shows", "My Top 3
/// Books" — manually curated, capped, independent of star ratings
/// (Part 42: a 5-star rating never auto-adds an item here).
class TopListRepository {
  TopListRepository(this._dao);

  final TopListDao _dao;

  static const _caps = {
    LibraryMediaType.film: 5,
    LibraryMediaType.tv: 5,
    LibraryMediaType.book: 3,
  };

  int capFor(LibraryMediaType type) => _caps[type]!;

  Stream<List<TopListEntry>> watch(String userId, LibraryMediaType type) {
    return _dao.watch(userId, type.name).map(_toDomainList);
  }

  Future<Result<void, Failure>> add(
    String userId,
    LibraryMediaType type,
    String libraryItemId,
  ) async {
    try {
      final existing = await _dao.get(userId, type.name);
      if (existing.any((e) => e.libraryItemId == libraryItemId)) {
        return const Ok(null);
      }
      final cap = capFor(type);
      if (existing.length >= cap) return Err(TopListFullFailure(cap));

      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsert(
        db.TopListItemsCompanion.insert(
          id: const Uuid().v4(),
          userId: userId,
          mediaType: type.name,
          libraryItemId: libraryItemId,
          rank: existing.length + 1,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('add failed: $e'));
    }
  }

  /// Removes [libraryItemId] and closes the resulting gap so ranks stay
  /// contiguous 1..N.
  Future<Result<void, Failure>> remove(
    String userId,
    LibraryMediaType type,
    String libraryItemId,
  ) async {
    try {
      final existing = await _dao.get(userId, type.name);
      final target = existing
          .where((e) => e.libraryItemId == libraryItemId)
          .firstOrNull;
      if (target == null) return const Ok(null);
      await _dao.remove(target.id);
      await _renumber(existing.where((e) => e.id != target.id).toList());
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('remove failed: $e'));
    }
  }

  /// Swaps [oldLibraryItemId] for [newLibraryItemId] at the same rank —
  /// Parts 7/16/24's "replace a film/show/book" action, distinct from
  /// removing then adding (which would move it to the end).
  Future<Result<void, Failure>> replace(
    String userId,
    LibraryMediaType type,
    String oldLibraryItemId,
    String newLibraryItemId,
  ) async {
    try {
      final existing = await _dao.get(userId, type.name);
      final target = existing
          .where((e) => e.libraryItemId == oldLibraryItemId)
          .firstOrNull;
      if (target == null) {
        return Err(NotFoundFailure('$oldLibraryItemId is not on this list'));
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsert(
        db.TopListItemsCompanion(
          id: Value(target.id),
          userId: Value(userId),
          mediaType: Value(type.name),
          libraryItemId: Value(newLibraryItemId),
          rank: Value(target.rank),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('replace failed: $e'));
    }
  }

  /// A full manual reorder — [orderedLibraryItemIds] is the complete new
  /// order, rank 1 first. Goes through negative placeholder ranks first:
  /// an arbitrary permutation can ask for a row to take a rank another
  /// surviving row currently holds, and `(userId, mediaType, rank)` is
  /// uniquely indexed, so writing final ranks directly can transiently
  /// collide with whichever row hasn't moved yet.
  Future<Result<void, Failure>> reorder(
    String userId,
    LibraryMediaType type,
    List<String> orderedLibraryItemIds,
  ) async {
    try {
      final existing = await _dao.get(userId, type.name);
      final byItemId = {for (final e in existing) e.libraryItemId: e};
      final now = DateTime.now().millisecondsSinceEpoch;

      Future<void> writeRank(db.TopListItem row, int rank) => _dao.upsert(
        db.TopListItemsCompanion(
          id: Value(row.id),
          userId: Value(userId),
          mediaType: Value(type.name),
          libraryItemId: Value(row.libraryItemId),
          rank: Value(rank),
          updatedAt: Value(now),
        ),
      );

      final rows = [
        for (final id in orderedLibraryItemIds)
          if (byItemId[id] case final row?) row,
      ];
      for (var i = 0; i < rows.length; i++) {
        await writeRank(rows[i], -(i + 1));
      }
      for (var i = 0; i < rows.length; i++) {
        await writeRank(rows[i], i + 1);
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('reorder failed: $e'));
    }
  }

  Future<void> _renumber(List<db.TopListItem> remaining) async {
    remaining.sort((a, b) => a.rank.compareTo(b.rank));
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < remaining.length; i++) {
      final row = remaining[i];
      if (row.rank == i + 1) continue;
      await _dao.upsert(
        db.TopListItemsCompanion(
          id: Value(row.id),
          userId: Value(row.userId),
          mediaType: Value(row.mediaType),
          libraryItemId: Value(row.libraryItemId),
          rank: Value(i + 1),
          updatedAt: Value(now),
        ),
      );
    }
  }

  List<TopListEntry> _toDomainList(List<db.TopListItem> rows) => rows
      .map(
        (r) => TopListEntry(
          id: r.id,
          libraryItemId: r.libraryItemId,
          rank: r.rank,
        ),
      )
      .toList();
}
