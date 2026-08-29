import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/document_links_table.dart';
import 'package:life_os/data/local/tables/documents_table.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents, DocumentLinks])
class DocumentDao extends DatabaseAccessor<AppDatabase> with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<Document>> watchAll(String userId) {
    final query = select(documents)
      ..where((d) => d.userId.equals(userId) & d.deletedAt.isNull())
      ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]);
    return query.watch();
  }

  /// §11.3. Documents attached to another entity — a join through
  /// `document_links`, same shape `note_dao.dart`'s `watchLinkedTo` uses.
  Stream<List<Document>> watchLinkedTo(String entityType, String entityId) {
    final query = select(documents).join([innerJoin(documentLinks, documentLinks.documentId.equalsExp(documents.id))])
      ..where(documentLinks.entityType.equals(entityType) & documentLinks.entityId.equals(entityId) & documents.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(documents.createdAt)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(documents)).toList());
  }

  Future<void> link({required String documentId, required String entityType, required String entityId}) => into(documentLinks)
      .insertOnConflictUpdate(
        DocumentLinksCompanion(
          documentId: Value(documentId),
          entityType: Value(entityType),
          entityId: Value(entityId),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> unlink({required String documentId, required String entityType, required String entityId}) => (delete(documentLinks)
        ..where((l) => l.documentId.equals(documentId) & l.entityType.equals(entityType) & l.entityId.equals(entityId)))
      .go();

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
