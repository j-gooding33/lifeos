import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_providers.g.dart';

/// `plans/` needs `LibraryItemRepository` for §16.5's occurrence-linking
/// flow, but never `lib/features/library/`'s own provider — that would be
/// a features-to-features import (rule 4). This wraps the same
/// `LibraryItemDao`/database `library/`'s own provider does, so a write
/// through either instance is visible to both.
@Riverpod(keepAlive: true)
LibraryItemRepository planMediaRepository(Ref ref) {
  return LibraryItemRepository(LibraryItemDao(ref.watch(appDatabaseProvider)));
}

@Riverpod(keepAlive: true)
PlanRepository planRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return PlanRepository(
    PlanDao(database),
    ActivityLogDao(database),
    libraryItemRepository: ref.watch(planMediaRepositoryProvider),
  );
}

/// The library item linked to an occurrence, for `OccurrenceSheet`'s
/// "linked film/show/book" display.
@riverpod
Stream<AppLibraryItem?> linkedLibraryItem(Ref ref, String libraryItemId) {
  return ref.watch(planMediaRepositoryProvider).watchById(libraryItemId);
}

/// §16.5's "choose a film" candidates — everything of [type] not already
/// watched/finished.
@riverpod
Stream<List<AppLibraryItem>> unwatchedLibraryItems(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref
      .watch(planMediaRepositoryProvider)
      .watchAll(userId, type)
      .map((items) => items.where((i) => i.status != LibraryItemStatus.done).toList());
}

@riverpod
Stream<List<AppPlan>> activePlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(planRepositoryProvider).watchActive(userId);
}

@riverpod
Stream<List<AppPlan>> habitPlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(planRepositoryProvider).watchHabits(userId);
}

@riverpod
Stream<List<AppPlan>> pausedPlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(planRepositoryProvider).watchPaused(userId);
}

@riverpod
Stream<List<AppPlan>> archivedPlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(planRepositoryProvider).watchArchived(userId);
}

@riverpod
Stream<AppPlan?> planById(Ref ref, String planId) {
  return ref.watch(planRepositoryProvider).watchById(planId);
}

@riverpod
Stream<List<AppOccurrence>> upcomingOccurrences(Ref ref, String planId) {
  return ref.watch(planRepositoryProvider).watchUpcoming(planId);
}

@riverpod
Stream<List<AppOccurrence>> historyOccurrences(
  Ref ref,
  String planId, {
  int limit = 20,
}) {
  return ref.watch(planRepositoryProvider).watchHistory(planId, limit: limit);
}

@riverpod
Stream<PlanStats> planStats(Ref ref, String planId) {
  return ref.watch(planRepositoryProvider).watchStats(planId);
}

@riverpod
Stream<AppOccurrence?> todayOccurrenceForPlan(Ref ref, String planId) {
  final today = CivilDate.fromDateTime(DateTime.now());
  return ref.watch(planRepositoryProvider).watchOccurrenceOn(planId, today);
}

@riverpod
Stream<AppOccurrence?> occurrenceById(Ref ref, String occurrenceId) {
  return ref.watch(planRepositoryProvider).watchOccurrenceById(occurrenceId);
}

@riverpod
Stream<List<AppOccurrence>> planOccurrencesInRange(
  Ref ref,
  String planId,
  CivilDate from,
  CivilDate through,
) {
  return ref
      .watch(planRepositoryProvider)
      .watchPlanOccurrencesInRange(planId, from, through);
}

/// §14.5: one range query per visible calendar period, shared by every
/// unified-calendar view.
@riverpod
Stream<List<AppOccurrence>> occurrencesInRange(
  Ref ref,
  CivilDate from,
  CivilDate through,
) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref
      .watch(planRepositoryProvider)
      .watchOccurrencesInRange(userId, from, through);
}

/// §9.5 trigger: run once whenever the Plans list is opened, so occurrence
/// generation and the missed sweep stay current without a true midnight
/// background job (see DECISIONS.md).
@riverpod
Future<void> plansMaintenance(Ref ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final repository = ref.watch(planRepositoryProvider);
  await repository.applyMissedSweep(userId);
  for (final plan in await repository.watchActive(userId).first) {
    await repository.ensureMaterialised(plan);
  }
  for (final plan in await repository.watchHabits(userId).first) {
    await repository.ensureMaterialised(plan);
  }
}
