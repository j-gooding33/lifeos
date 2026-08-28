import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/journal_entries_table.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  Stream<List<JournalEntry>> watchRecent(String userId, {int limit = 60}) {
    final query = select(journalEntries)
      ..where((j) => j.userId.equals(userId) & j.deletedAt.isNull())
      ..orderBy([(j) => OrderingTerm.desc(j.date)])
      ..limit(limit);
    return query.watch();
  }

  Stream<JournalEntry?> watchByDate(String userId, String date) {
    final query = select(journalEntries)..where((j) => j.userId.equals(userId) & j.date.equals(date) & j.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<JournalEntry?> getByDate(String userId, String date) {
    final query = select(journalEntries)..where((j) => j.userId.equals(userId) & j.date.equals(date) & j.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  Future<void> upsert(JournalEntriesCompanion entry) => into(journalEntries).insertOnConflictUpdate(entry);
}
