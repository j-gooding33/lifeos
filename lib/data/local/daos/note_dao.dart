import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/note_links_table.dart';
import 'package:life_os/data/local/tables/notes_table.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes, NoteLinks])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  Stream<List<Note>> watchAll(String userId) {
    final query = select(notes)
      ..where((n) => n.userId.equals(userId) & n.deletedAt.isNull())
      ..orderBy([(n) => OrderingTerm.desc(n.pinned), (n) => OrderingTerm.desc(n.updatedAt)]);
    return query.watch();
  }

  Stream<Note?> watchById(String id) {
    final query = select(notes)..where((n) => n.id.equals(id) & n.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<void> upsert(NotesCompanion entry) => into(notes).insertOnConflictUpdate(entry);

  Future<void> setPinned(String id, {required bool pinned, required int now}) =>
      (update(notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(pinned: Value(pinned), updatedAt: Value(now)),
      );

  Future<void> softDelete(String id, int now) =>
      (update(notes)..where((n) => n.id.equals(id))).write(NotesCompanion(deletedAt: Value(now)));

  /// §17.2. Notes attached to any other entity — a join through `note_links`.
  Stream<List<Note>> watchLinkedTo(String entityType, String entityId) {
    final query = select(notes).join([innerJoin(noteLinks, noteLinks.noteId.equalsExp(notes.id))])
      ..where(noteLinks.entityType.equals(entityType) & noteLinks.entityId.equals(entityId) & notes.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(notes.updatedAt)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(notes)).toList());
  }

  Stream<List<NoteLink>> watchLinksForNote(String noteId) => (select(noteLinks)..where((l) => l.noteId.equals(noteId))).watch();

  Future<void> link({required String noteId, required String entityType, required String entityId}) => into(noteLinks)
      .insertOnConflictUpdate(
        NoteLinksCompanion(
          noteId: Value(noteId),
          entityType: Value(entityType),
          entityId: Value(entityId),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> unlink({required String noteId, required String entityType, required String entityId}) =>
      (delete(noteLinks)..where((l) => l.noteId.equals(noteId) & l.entityType.equals(entityType) & l.entityId.equals(entityId))).go();
}
