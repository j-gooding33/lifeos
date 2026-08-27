import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/collection_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_collection.dart';
import 'package:uuid/uuid.dart';

/// M8 Part 28 (§15.2). CRUD over `collections`, plus membership over
/// `collection_items`. Only owns which items belong to which collection —
/// like `TopListRepository`, callers join with `LibraryItemRepository` for
/// display (title, poster, etc.).
class CollectionRepository {
  CollectionRepository(this._dao);

  final CollectionDao _dao;

  /// The only entity type in play until Notes exists as a real feature —
  /// see `AppCollectionItem`'s doc comment.
  static const _entityType = 'libraryItem';

  Stream<List<AppCollection>> watchAll(String userId) {
    return _dao.watchAll(userId).map((rows) => rows.map(_toDomain).toList());
  }

  Stream<AppCollection?> watchById(String id) {
    return _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));
  }

  Future<Result<AppCollection, Failure>> create({
    required String userId,
    required String title,
    String? description,
    MediaType? itemType,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = const Uuid().v4();
      await _dao.upsert(
        db.CollectionsCompanion.insert(
          id: id,
          userId: userId,
          title: title,
          description: Value(description),
          itemType: Value(itemType?.name),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return Ok(AppCollection(id: id, userId: userId, title: title, description: description, itemType: itemType));
    } on Object catch (e) {
      return Err(DatabaseFailure('create failed: $e'));
    }
  }

  Future<Result<void, Failure>> rename(String id, String title) async {
    try {
      await _dao.rename(id, title, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('rename failed: $e'));
    }
  }

  Future<Result<void, Failure>> delete(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('delete failed: $e'));
    }
  }

  Stream<List<String>> watchItemIds(String collectionId) {
    return _dao.watchItems(collectionId).map((rows) => rows.map((r) => r.entityId).toList());
  }

  /// Every collection that already contains [libraryItemId] — the "Add to
  /// collection" menu uses this to show a checkmark instead of letting a
  /// user add the same item twice.
  Stream<Set<String>> watchCollectionIdsContaining(String libraryItemId) {
    return _dao.watchForEntity(_entityType, libraryItemId).map((rows) => rows.map((r) => r.collectionId).toSet());
  }

  Future<Result<void, Failure>> addItem(String collectionId, String libraryItemId) async {
    try {
      await _dao.addItem(
        db.CollectionItemsCompanion.insert(
          collectionId: collectionId,
          entityType: _entityType,
          entityId: libraryItemId,
          addedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('addItem failed: $e'));
    }
  }

  Future<Result<void, Failure>> removeItem(String collectionId, String libraryItemId) async {
    try {
      await _dao.removeItem(collectionId, _entityType, libraryItemId);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('removeItem failed: $e'));
    }
  }

  MediaType? _parseItemType(String? raw) {
    if (raw == null) return null;
    for (final type in MediaType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }

  AppCollection _toDomain(db.Collection row) {
    return AppCollection(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      itemType: _parseItemType(row.itemType),
    );
  }
}
