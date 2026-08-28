import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_journal_entry.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:uuid/uuid.dart';

/// §22.1. One entry per day. `getOrCreate` is the primary entry point — the
/// journal screen always wants "today's entry, creating it if this is the
/// first open today" rather than a bare create call.
class JournalRepository {
  JournalRepository(this._dao);

  final JournalDao _dao;

  Stream<List<AppJournalEntry>> watchRecent(String userId, {int limit = 60}) =>
      _dao.watchRecent(userId, limit: limit).map(_toDomainList);

  Stream<AppJournalEntry?> watchByDate(String userId, CivilDate date) =>
      _dao.watchByDate(userId, date.toIso()).map((row) => row == null ? null : _toDomain(row));

  Future<Result<AppJournalEntry, Failure>> getOrCreate({required String userId, required CivilDate date}) async {
    try {
      final existing = await _dao.getByDate(userId, date.toIso());
      if (existing != null) return Ok(_toDomain(existing));
      final entry = AppJournalEntry(id: const Uuid().v4(), userId: userId, date: date);
      await _save(entry);
      return Ok(entry);
    } on Object catch (e) {
      return Err(DatabaseFailure('getOrCreate failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateEntry(AppJournalEntry entry) async {
    try {
      await _save(entry);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateEntry failed: $e'));
    }
  }

  Future<void> _save(AppJournalEntry entry) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.JournalEntriesCompanion(
        id: Value(entry.id),
        userId: Value(entry.userId),
        date: Value(entry.date.toIso()),
        blocks: Value(jsonEncode(entry.blocks.map((b) => b.toJson()).toList())),
        plainText: Value(entry.plainText),
        mood: Value(entry.mood),
        createdAt: Value(entry.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppJournalEntry> _toDomainList(List<db.JournalEntry> rows) => rows.map(_toDomain).toList();

  AppJournalEntry _toDomain(db.JournalEntry row) {
    final rawBlocks = row.blocks == null ? const <dynamic>[] : jsonDecode(row.blocks!) as List<dynamic>;
    return AppJournalEntry(
      id: row.id,
      userId: row.userId,
      date: CivilDate.parse(row.date),
      blocks: rawBlocks.map((b) => NoteBlock.fromJson(b as Map<String, Object?>)).toList(),
      mood: row.mood,
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      updatedAt: row.updatedAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.updatedAt!),
    );
  }
}
