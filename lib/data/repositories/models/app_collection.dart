import 'package:life_os/data/media/media_types.dart';

/// M8 Part 28 (§15.2). A named, ordered, polymorphic list backed by
/// `collections`/`collection_items` (§23.3). Manual only — smart
/// collections (`isSmart`/`smartQuery`) are spec'd for M15 and not
/// surfaced here.
class AppCollection {
  const AppCollection({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.itemType,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;

  /// Restricts what can be added to this collection when set (e.g. a
  /// films-only collection); `null` allows any media type, matching the
  /// table's own polymorphic design.
  final MediaType? itemType;
}

/// One entry in a collection. `entityType` is always `'libraryItem'` for
/// now, since films, TV shows and books all live in `library_items`
/// (§16.3) — the column exists so a future entity (e.g. a Note) can join
/// a collection without a schema change.
class AppCollectionItem {
  const AppCollectionItem({
    required this.collectionId,
    required this.entityType,
    required this.entityId,
    this.addedAt,
  });

  final String collectionId;
  final String entityType;
  final String entityId;
  final DateTime? addedAt;
}
