import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/first_value.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/dashboard_card_dao.dart';
import 'package:life_os/data/local/daos/finance_dao.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/repositories/dashboard_card_repository.dart';
import 'package:life_os/data/repositories/finance_repository.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_dashboard_card.dart';
import 'package:life_os/data/repositories/models/app_expense.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/stats_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

/// One Upcoming row's worth of data — a day, or the undated bucket.
class UpcomingBucket {
  const UpcomingBucket({required this.count, required this.firstTitle});

  final int count;

  /// `null` when [count] is 0.
  final String? firstTitle;

  bool get isEmpty => count == 0;
}

/// A habit's today-status for the `habits` card's ring row (§5.3).
class HabitRingItem {
  const HabitRingItem({required this.plan, required this.completedToday});

  final AppPlan plan;
  final bool completedToday;
}

/// A project plus its derived progress, the same `done / total` tasks
/// arithmetic `ProjectsScreen` itself uses — `null` when it has no tasks
/// yet, same meaning as there.
class ProjectProgressItem {
  const ProjectProgressItem({required this.project, required this.progress});

  final AppProject project;
  final double? progress;
}

/// §5.5: "a single HomeSnapshot provider that runs one composed query."
/// Repositories are constructed straight from DAOs rather than by
/// importing Tasks/Plans/Goals/Projects/Journal/Finance's own provider
/// files (CLAUDE.md rule 4) — same pattern as `StatsRepository`.
class HomeSnapshot {
  const HomeSnapshot({
    required this.focusItems,
    required this.doneToday,
    required this.totalToday,
    required this.upcomingByDay,
    required this.upcomingUndated,
    required this.recent,
    required this.plansToday,
    required this.plansTodayTitles,
    required this.habits,
    required this.goals,
    required this.projects,
    required this.plansCompletedToday,
    required this.currentStreakDays,
    required this.journalWrittenToday,
    required this.spentThisMonthMinor,
    required this.monthlyBudgetMinor,
    required this.currency,
  });

  /// Capped at 6 (§5.3's `focus` card).
  final List<AppTask> focusItems;
  final int doneToday;
  final int totalToday;

  /// Next 7 days, keyed by civil date (§5.3's `upcoming` card).
  final Map<String, UpcomingBucket> upcomingByDay;

  /// Upcoming tasks with no due date at all — item 6/7: these must still
  /// surface on Home, just not attached to any one day.
  final UpcomingBucket upcomingUndated;

  final List<AppTask> recent;

  /// Today's non-habit occurrences (§5.3's `plansToday`), plan titles
  /// keyed by id since a plan can appear more than once (multiple
  /// occurrences on the same day is rare but not impossible).
  final List<AppOccurrence> plansToday;
  final Map<String, AppPlan> plansTodayTitles;

  final List<HabitRingItem> habits;

  /// Active goals, capped at 3 (§5.3's `goals`).
  final List<AppGoal> goals;

  /// Active projects, capped at 3 (§5.3's `projects`).
  final List<ProjectProgressItem> projects;

  final int plansCompletedToday;
  final int currentStreakDays;
  final bool journalWrittenToday;
  final int spentThisMonthMinor;
  final int? monthlyBudgetMinor;
  final String currency;

  bool get allDoneToday => totalToday > 0 && doneToday == totalToday;
  bool get hasNothingToday => totalToday == 0;

  bool get hasNothingUpcoming =>
      upcomingUndated.isEmpty && upcomingByDay.values.every((b) => b.isEmpty);
}

/// Pure — groups an already-fetched upcoming-task list into per-day buckets
/// plus one undated bucket (item 6/7). Split out from [homeSnapshot] itself
/// so it's unit-testable without a database.
({Map<String, UpcomingBucket> byDay, UpcomingBucket undated}) bucketUpcoming(List<AppTask> upcoming) {
  final byDay = <String, List<AppTask>>{};
  final undated = <AppTask>[];
  for (final task in upcoming) {
    final date = task.dueDate;
    if (date == null) {
      undated.add(task);
    } else {
      (byDay[date] ??= []).add(task);
    }
  }
  return (
    byDay: {
      for (final entry in byDay.entries)
        entry.key: UpcomingBucket(count: entry.value.length, firstTitle: entry.value.first.title),
    },
    undated: UpcomingBucket(count: undated.length, firstTitle: undated.isEmpty ? null : undated.first.title),
  );
}

/// Consecutive days ending today with at least one completion, from the
/// same `dailyActivityScores` bucketing Your Year's grid uses.
int currentStreak(Map<CivilDate, int> scores, CivilDate today) {
  var streak = 0;
  var day = today;
  while ((scores[day] ?? 0) > 0) {
    streak++;
    day = day.addDays(-1);
  }
  return streak;
}

@Riverpod(keepAlive: true)
TaskRepository homeTaskRepository(Ref ref) => TaskRepository(TaskDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
PlanRepository homePlanRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlanRepository(PlanDao(db), ActivityLogDao(db));
}

@Riverpod(keepAlive: true)
GoalRepository homeGoalRepository(Ref ref) => GoalRepository(GoalDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
ProjectRepository homeProjectRepository(Ref ref) => ProjectRepository(ProjectDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
FinanceRepository homeFinanceRepository(Ref ref) => FinanceRepository(FinanceDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
DashboardCardRepository dashboardCardRepository(Ref ref) =>
    DashboardCardRepository(DashboardCardDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
StatsRepository homeStatsRepository(Ref ref) {
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
Stream<List<AppDashboardCard>> dashboardCards(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  await ref.watch(dashboardCardRepositoryProvider).ensureDefaults(userId);
  yield* ref.watch(dashboardCardRepositoryProvider).watchAll(userId);
}

// The stream wrappers below exist so §5.5's "recompute on ... any write" is
// real, not just true at first load: `ref.watch(xProvider.future)` inside
// `homeSnapshot` creates a live dependency on the underlying Drift stream,
// so completing a task/occurrence/habit anywhere in the app rebuilds Home
// automatically. A one-shot `firstValue()` read (used further down for
// Goals/Projects/Journal/Finance/streak) would not do that — those are
// lower-frequency, glance-and-move-on cards where refreshing on next visit
// is an acceptable, documented trade-off (see DECISIONS.md); the
// inline-checkable ones (focus, upcoming, recent, plansToday, habits) are
// not.
@riverpod
Stream<List<AppTask>> homeAllTasksDueToday(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homeTaskRepositoryProvider).watchAllDueOn(userId, CivilDate.fromDateTime(DateTime.now()));
}

@riverpod
Stream<List<AppTask>> homeTodayTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homeTaskRepositoryProvider).watchToday(userId, CivilDate.fromDateTime(DateTime.now()));
}

@riverpod
Stream<List<AppTask>> homeUpcomingTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homeTaskRepositoryProvider).watchUpcoming(userId, CivilDate.fromDateTime(DateTime.now()));
}

@riverpod
Stream<List<AppTask>> homeRecentTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homeTaskRepositoryProvider).watchRecentlyCreated(userId);
}

@riverpod
Stream<List<AppOccurrence>> homeTodaysOccurrences(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  final today = CivilDate.fromDateTime(DateTime.now());
  yield* ref.watch(homePlanRepositoryProvider).watchOccurrencesInRange(userId, today, today);
}

@riverpod
Stream<List<AppPlan>> homeActivePlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homePlanRepositoryProvider).watchActive(userId);
}

@riverpod
Stream<List<AppPlan>> homeHabitPlans(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(homePlanRepositoryProvider).watchHabits(userId);
}

@riverpod
Stream<AppOccurrence?> homeHabitOccurrenceOn(Ref ref, String planId, CivilDate date) {
  return ref.watch(homePlanRepositoryProvider).watchOccurrenceOn(planId, date);
}

@riverpod
Future<HomeSnapshot> homeSnapshot(Ref ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final today = CivilDate.fromDateTime(DateTime.now());

  final allToday = await ref.watch(homeAllTasksDueTodayProvider.future);
  final focusItems = await ref.watch(homeTodayTasksProvider.future);
  final upcoming = await ref.watch(homeUpcomingTasksProvider.future);
  final recent = await ref.watch(homeRecentTasksProvider.future);
  final bucketed = bucketUpcoming(upcoming);

  final todaysOccurrences = await ref.watch(homeTodaysOccurrencesProvider.future);
  final activePlans = await ref.watch(homeActivePlansProvider.future);
  final habitPlans = await ref.watch(homeHabitPlansProvider.future);
  final habitPlanIds = habitPlans.map((p) => p.id).toSet();
  final plansTodayTitles = {for (final p in [...activePlans, ...habitPlans]) p.id: p};
  final plansToday = todaysOccurrences
      .where((o) => o.status != OccurrenceStatus.cancelled && !habitPlanIds.contains(o.planId))
      .toList();
  final plansCompletedToday = todaysOccurrences.where((o) => o.status == OccurrenceStatus.completed).length;

  final habits = <HabitRingItem>[];
  for (final habit in habitPlans) {
    final occurrence = await ref.watch(homeHabitOccurrenceOnProvider(habit.id, today).future);
    habits.add(HabitRingItem(plan: habit, completedToday: occurrence?.status == OccurrenceStatus.completed));
  }

  // Goals/Projects/Journal/Finance/streak: one-shot reads, refreshed on
  // Home's next rebuild rather than live — see the doc comment above the
  // stream wrappers for why this split is deliberate, not an oversight.
  final goalRepository = ref.watch(homeGoalRepositoryProvider);
  final allGoals = await firstValue(goalRepository.watchAll(userId));
  final goals = allGoals.where((g) => g.status == GoalStatus.active).take(3).toList();

  final taskRepository = ref.watch(homeTaskRepositoryProvider);
  final projectRepository = ref.watch(homeProjectRepositoryProvider);
  final allProjects = await firstValue(projectRepository.watchAll(userId));
  final activeProjects = allProjects.where((p) => p.status == ProjectStatus.active).take(3);
  final projects = <ProjectProgressItem>[];
  for (final project in activeProjects) {
    final tasks = await firstValue(taskRepository.watchByProjectId(project.id));
    final progress = tasks.isEmpty ? null : tasks.where((t) => t.isCompleted).length / tasks.length;
    projects.add(ProjectProgressItem(project: project, progress: progress));
  }

  final journalEntry = await firstValue(ref.watch(homeStatsRepositoryProvider).journalRepository.watchByDate(userId, today));
  final journalWrittenToday = journalEntry != null && journalEntry.plainText.isNotEmpty;

  final scores = await ref
      .watch(homeStatsRepositoryProvider)
      .dailyActivityScores(userId: userId, from: today.addDays(-60), to: today);
  final streak = currentStreak(scores, today);

  final profile = await firstValue(ref.watch(profileRepositoryProvider).watchProfile(userId));
  final currency = profile?.currency ?? 'GBP';

  final financeRepository = ref.watch(homeFinanceRepositoryProvider);
  final expenses = await firstValue(financeRepository.watchExpenses(userId));
  final monthStart = CivilDate(today.year, today.month, 1);
  final spentThisMonthMinor = expenses
      .where((e) => e.type == ExpenseType.expense && !e.date.isBefore(monthStart) && !e.date.isAfter(today))
      .fold<int>(0, (sum, e) => sum + e.amountMinor);
  final budgets = await firstValue(financeRepository.watchBudgets(userId));
  final overallBudget = budgets.where((b) => b.categoryId == null).firstOrNull;

  return HomeSnapshot(
    // Cap at 6 (§5.3) — Home never renders an unbounded list (§5.6).
    focusItems: focusItems.take(6).toList(),
    doneToday: allToday.where((t) => t.isCompleted).length,
    totalToday: allToday.length,
    upcomingByDay: bucketed.byDay,
    upcomingUndated: bucketed.undated,
    recent: recent,
    plansToday: plansToday,
    plansTodayTitles: plansTodayTitles,
    habits: habits,
    goals: goals,
    projects: projects,
    plansCompletedToday: plansCompletedToday,
    currentStreakDays: streak,
    journalWrittenToday: journalWrittenToday,
    spentThisMonthMinor: spentThisMonthMinor,
    monthlyBudgetMinor: overallBudget?.amountMinor,
    currency: currency,
  );
}
