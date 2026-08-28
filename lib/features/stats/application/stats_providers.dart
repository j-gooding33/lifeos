import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/day_detail.dart';
import 'package:life_os/data/repositories/models/insight.dart';
import 'package:life_os/data/repositories/models/period_stats.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/stats_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_providers.g.dart';

/// Constructed straight from DAOs, not by importing Tasks/Plans/Goals/
/// Library/Journal's own provider files (CLAUDE.md rule 4) — same pattern
/// as `LNotesSection`/`resolveDomainColour`/`dataSettingsSearchRepository`.
@Riverpod(keepAlive: true)
StatsRepository statsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return StatsRepository(
    taskRepository: TaskRepository(TaskDao(db)),
    planRepository: PlanRepository(PlanDao(db), ActivityLogDao(db)),
    goalRepository: GoalRepository(GoalDao(db)),
    libraryItemRepository: LibraryItemRepository(LibraryItemDao(db)),
    journalRepository: JournalRepository(JournalDao(db)),
  );
}

@riverpod
Future<PeriodStats> periodStats(Ref ref, CivilDate from, CivilDate to) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(statsRepositoryProvider).statsForPeriod(userId: userId, from: from, to: to);
}

@riverpod
Future<Map<CivilDate, int>> dailyActivityScores(Ref ref, CivilDate from, CivilDate to) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(statsRepositoryProvider).dailyActivityScores(userId: userId, from: from, to: to);
}

@riverpod
Future<Set<CivilDate>> datesWithCompletedMilestone(Ref ref, CivilDate from, CivilDate to) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(statsRepositoryProvider).datesWithCompletedMilestone(userId: userId, from: from, to: to);
}

@riverpod
Future<DayDetail> dayDetail(Ref ref, CivilDate date) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(statsRepositoryProvider).dayDetail(userId: userId, date: date);
}

@riverpod
Future<List<Insight>> insights(Ref ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(statsRepositoryProvider).insights(userId: userId);
}
