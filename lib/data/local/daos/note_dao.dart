import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/notes_table.dart';

part 'note_dao.g.dart';

@DriftAccessor(tables: [Notes])
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
}
