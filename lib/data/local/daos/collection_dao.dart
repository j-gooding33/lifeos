import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/collection_items_table.dart';
import 'package:life_os/data/local/tables/collections_table.dart';

part 'collection_dao.g.dart';

@DriftAccessor(tables: [Collections, CollectionItems])
class CollectionDao extends DatabaseAccessor<AppDatabase> with _$CollectionDaoMixin {
  CollectionDao(super.db);

  Stream<List<Collection>> watchAll(String userId) {
    final query = select(collections)
      ..where((c) => c.userId.equals(userId) & c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.title)]);
    return query.watch();
  }

  Stream<Collection?> watchById(String id) {
    final query = select(collections)..where((c) => c.id.equals(id) & c.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<void> upsert(CollectionsCompanion entry) => into(collections).insertOnConflictUpdate(entry);

  Future<void> rename(String id, String title, int updatedAt) => (update(collections)..where((c) => c.id.equals(id))).write(
    CollectionsCompanion(title: Value(title), updatedAt: Value(updatedAt), dirty: const Value(true)),
  );

  Future<void> softDelete(String id, int deletedAt) => (update(collections)..where((c) => c.id.equals(id))).write(
    CollectionsCompanion(deletedAt: Value(deletedAt), dirty: const Value(true)),
  );

  Stream<List<CollectionItem>> watchItems(String collectionId) {
    final query = select(collectionItems)
      ..where((i) => i.collectionId.equals(collectionId))
      ..orderBy([(i) => OrderingTerm.asc(i.addedAt)]);
    return query.watch();
  }

  Stream<List<CollectionItem>> watchForEntity(String entityType, String entityId) {
    final query = select(collectionItems)..where((i) => i.entityType.equals(entityType) & i.entityId.equals(entityId));
    return query.watch();
  }

  Future<void> addItem(CollectionItemsCompanion entry) => into(collectionItems).insertOnConflictUpdate(entry);

  Future<void> removeItem(String collectionId, String entityType, String entityId) => (delete(
    collectionItems,
  )..where((i) => i.collectionId.equals(collectionId) & i.entityType.equals(entityType) & i.entityId.equals(entityId))).go();
}
