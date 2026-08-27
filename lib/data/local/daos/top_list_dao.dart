import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/top_list_items_table.dart';

part 'top_list_dao.g.dart';

@DriftAccessor(tables: [TopListItems])
class TopListDao extends DatabaseAccessor<AppDatabase> with _$TopListDaoMixin {
  TopListDao(super.db);

  Stream<List<TopListItem>> watch(String userId, String mediaType) {
    final query = select(topListItems)
      ..where((t) => t.userId.equals(userId) & t.mediaType.equals(mediaType))
      ..orderBy([(t) => OrderingTerm.asc(t.rank)]);
    return query.watch();
  }

  Future<List<TopListItem>> get(String userId, String mediaType) {
    return (select(topListItems)
          ..where(
            (t) => t.userId.equals(userId) & t.mediaType.equals(mediaType),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.rank)]))
        .get();
  }

  Future<void> upsert(TopListItemsCompanion entry) =>
      into(topListItems).insertOnConflictUpdate(entry);

  Future<void> remove(String id) =>
      (delete(topListItems)..where((t) => t.id.equals(id))).go();
}
