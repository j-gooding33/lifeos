import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_providers.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) {
  return GoalRepository(GoalDao(ref.watch(appDatabaseProvider)));
}

/// `tasks/`'s own `PlanRepository` instance for §12.3's "linked plans"
/// list — never `lib/features/plans/`'s own provider (rule 4), same
/// pattern as `library/`'s `libraryPlanRepositoryProvider`.
@Riverpod(keepAlive: true)
PlanRepository goalPlanRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return PlanRepository(PlanDao(database), ActivityLogDao(database));
}

@riverpod
Stream<List<AppPlan>> plansForGoal(Ref ref, String goalId) {
  return ref.watch(goalPlanRepositoryProvider).watchByGoalId(goalId);
}

@riverpod
Stream<List<AppGoal>> allGoals(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(goalRepositoryProvider).watchAll(userId);
}

@riverpod
Stream<AppGoal?> goalById(Ref ref, String goalId) {
  return ref.watch(goalRepositoryProvider).watchById(goalId);
}

@riverpod
Stream<List<AppGoalContribution>> goalContributions(Ref ref, String goalId) {
  return ref.watch(goalRepositoryProvider).watchContributions(goalId);
}

@riverpod
Stream<List<AppGoalMilestone>> goalMilestones(Ref ref, String goalId) {
  return ref.watch(goalRepositoryProvider).watchMilestones(goalId);
}
