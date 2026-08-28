import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/links_table.dart';

part 'link_dao.g.dart';

@DriftAccessor(tables: [Links])
class LinkDao extends DatabaseAccessor<AppDatabase> with _$LinkDaoMixin {
  LinkDao(super.db);

  Stream<List<Link>> watchAll(String userId) {
    final query = select(links)
      ..where((l) => l.userId.equals(userId) & l.deletedAt.isNull())
      ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]);
    return query.watch();
  }

  Future<void> upsert(LinksCompanion entry) => into(links).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(links)..where((l) => l.id.equals(id))).write(LinksCompanion(deletedAt: Value(now)));
}
