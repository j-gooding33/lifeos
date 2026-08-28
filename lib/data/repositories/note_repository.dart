import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/note_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:uuid/uuid.dart';

/// §17.1. The `notes` table has existed since the original schema; this is
/// its first repository. `plainText` is written on every save (this
/// repository's job, per §17.1 — "maintained on every save") even though
/// nothing reads it yet (§18's FTS5 index is unbuilt) — it's ready the
/// moment that ships.
class NoteRepository {
  NoteRepository(this._dao);

  final NoteDao _dao;

  Stream<List<AppNote>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Stream<AppNote?> watchById(String id) => _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));

  /// §17.2. Notes linked to another entity (task, plan, project, goal,
  /// occurrence, film, book, journal entry) — bidirectional in the UI, but
  /// `note_links` itself only stores the note→entity direction.
  Stream<List<AppNote>> watchLinkedTo(String entityType, String entityId) =>
      _dao.watchLinkedTo(entityType, entityId).map(_toDomainList);

  Future<Result<void, Failure>> linkNote({required String noteId, required String entityType, required String entityId}) async {
    try {
      await _dao.link(noteId: noteId, entityType: entityType, entityId: entityId);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('linkNote failed: $e'));
    }
  }

  Future<Result<void, Failure>> unlinkNote({required String noteId, required String entityType, required String entityId}) async {
    try {
      await _dao.unlink(noteId: noteId, entityType: entityType, entityId: entityId);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('unlinkNote failed: $e'));
    }
  }

  Future<Result<AppNote, Failure>> createNote({
    required String userId,
    String? title,
    List<NoteBlock> blocks = const [],
    String? folderId,
    String? colour,
  }) async {
    try {
      final note = AppNote(id: const Uuid().v4(), userId: userId, title: title, blocks: blocks, folderId: folderId, colour: colour);
      await _save(note);
      return Ok(note);
    } on Object catch (e) {
      return Err(DatabaseFailure('createNote failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateNote(AppNote note) async {
    try {
      await _save(note);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateNote failed: $e'));
    }
  }

  Future<Result<void, Failure>> setPinned(String id, {required bool pinned}) async {
    try {
      await _dao.setPinned(id, pinned: pinned, now: DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setPinned failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteNote(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteNote failed: $e'));
    }
  }

  Future<void> _save(AppNote note) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.NotesCompanion(
        id: Value(note.id),
        userId: Value(note.userId),
        title: Value(note.title),
        blocks: Value(jsonEncode(note.blocks.map((b) => b.toJson()).toList())),
        plainText: Value(note.plainText),
        folderId: Value(note.folderId),
        pinned: Value(note.pinned),
        colour: Value(note.colour),
        createdAt: Value(note.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppNote> _toDomainList(List<db.Note> rows) => rows.map(_toDomain).toList();

  AppNote _toDomain(db.Note row) {
    final rawBlocks = jsonDecode(row.blocks) as List<dynamic>;
    return AppNote(
      id: row.id,
      userId: row.userId,
      title: row.title,
      blocks: rawBlocks.map((b) => NoteBlock.fromJson(b as Map<String, Object?>)).toList(),
      folderId: row.folderId,
      pinned: row.pinned,
      colour: row.colour,
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      updatedAt: row.updatedAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.updatedAt!),
    );
  }
}
