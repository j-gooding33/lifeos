import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/models/app_journal_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journal_providers.g.dart';

@Riverpod(keepAlive: true)
JournalRepository journalRepository(Ref ref) {
  return JournalRepository(JournalDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppJournalEntry>> recentJournalEntries(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(journalRepositoryProvider).watchRecent(userId);
}

@riverpod
Stream<AppJournalEntry?> journalEntryByDate(Ref ref, CivilDate date) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(journalRepositoryProvider).watchByDate(userId, date);
}
