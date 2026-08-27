import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/library_items_table.dart';

part 'library_item_dao.g.dart';

@DriftAccessor(tables: [LibraryItems])
class LibraryItemDao extends DatabaseAccessor<AppDatabase>
    with _$LibraryItemDaoMixin {
  LibraryItemDao(super.db);

  Stream<List<LibraryItem>> watchByStatus(
    String userId,
    String mediaType,
    String status,
  ) {
    final query = select(libraryItems)
      ..where(
        (i) =>
            i.userId.equals(userId) &
            i.deletedAt.isNull() &
            i.mediaType.equals(mediaType) &
            i.status.equals(status),
      )
      ..orderBy([(i) => OrderingTerm.desc(i.addedAt)]);
    return query.watch();
  }

  Stream<List<LibraryItem>> watchAllForType(String userId, String mediaType) {
    final query = select(libraryItems)
      ..where(
        (i) =>
            i.userId.equals(userId) &
            i.deletedAt.isNull() &
            i.mediaType.equals(mediaType),
      );
    return query.watch();
  }

  Stream<List<LibraryItem>> watchFavourites(String userId, String mediaType) {
    final query = select(libraryItems)
      ..where(
        (i) =>
            i.userId.equals(userId) &
            i.deletedAt.isNull() &
            i.mediaType.equals(mediaType) &
            i.isFavourite.equals(true),
      )
      ..orderBy([(i) => OrderingTerm.desc(i.addedAt)]);
    return query.watch();
  }

  Stream<List<LibraryItem>> watchRated(String userId, String mediaType) {
    final query = select(libraryItems)
      ..where(
        (i) =>
            i.userId.equals(userId) &
            i.deletedAt.isNull() &
            i.mediaType.equals(mediaType) &
            i.rating.isNotNull(),
      );
    return query.watch();
  }

  Future<LibraryItem?> getById(String id) =>
      (select(libraryItems)..where((i) => i.id.equals(id))).getSingleOrNull();

  Stream<LibraryItem?> watchById(String id) =>
      (select(libraryItems)..where((i) => i.id.equals(id))).watchSingleOrNull();

  /// §16.7: "same film added twice — adding again just opens the existing
  /// item," backed by the unique `(providerId, externalId, userId)` index.
  Future<LibraryItem?> getByExternalId(
    String userId,
    String providerId,
    String externalId,
  ) {
    return (select(libraryItems)..where(
          (i) =>
              i.userId.equals(userId) &
              i.providerId.equals(providerId) &
              i.externalId.equals(externalId) &
              i.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  Future<void> upsert(LibraryItemsCompanion entry) =>
      into(libraryItems).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(libraryItems)..where((i) => i.id.equals(id))).write(
        LibraryItemsCompanion(deletedAt: Value(now)),
      );
}
