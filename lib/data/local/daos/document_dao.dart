import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/documents_table.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents])
class DocumentDao extends DatabaseAccessor<AppDatabase> with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<Document>> watchAll(String userId) {
    final query = select(documents)
      ..where((d) => d.userId.equals(userId) & d.deletedAt.isNull())
      ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]);
    return query.watch();
  }

  Future<int> totalSizeBytes(String userId) async {
    final query = selectOnly(documents)
      ..addColumns([documents.fileSizeBytes.sum()])
      ..where(documents.userId.equals(userId) & documents.deletedAt.isNull());
    final row = await query.getSingle();
    return row.read(documents.fileSizeBytes.sum()) ?? 0;
  }

  Future<Document?> getById(String id) => (select(documents)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<void> upsert(DocumentsCompanion entry) => into(documents).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(documents)..where((d) => d.id.equals(id))).write(DocumentsCompanion(deletedAt: Value(now)));
}
