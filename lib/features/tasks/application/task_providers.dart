import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepository(TaskDao(ref.watch(appDatabaseProvider)));
}

/// Named distinctly from `onboarding_providers.dart`'s own
/// `projectRepositoryProvider` (that file constructs its own instance
/// directly from the DAO too, per rule 4 — see DECISIONS.md) so nothing
/// that imports both ever collides.
@Riverpod(keepAlive: true)
ProjectRepository projectsRepository(Ref ref) {
  return ProjectRepository(ProjectDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppProject>> allProjects(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(projectsRepositoryProvider).watchAll(userId);
}

@riverpod
Stream<AppProject?> projectById(Ref ref, String projectId) {
  return ref.watch(projectsRepositoryProvider).watchById(projectId);
}

@riverpod
Stream<List<AppTask>> tasksForProject(Ref ref, String projectId) {
  return ref.watch(taskRepositoryProvider).watchByProjectId(projectId);
}

CivilDate _today() => CivilDate.fromDateTime(DateTime.now());

@riverpod
Stream<List<AppTask>> todayTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchToday(userId, _today());
}

@riverpod
Stream<List<AppTask>> overdueTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchOverdue(userId, _today());
}

@riverpod
Stream<List<AppTask>> upcomingTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchUpcoming(userId, _today());
}

/// Future-dated only, excluding undated tasks — feeds the Today tab's
/// "beyond today" section specifically (see `tasks_screen.dart`), which
/// orders undated before future-dated rather than [upcomingTasksProvider]'s
/// dated-first ordering.
@riverpod
Stream<List<AppTask>> futureDatedTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchFutureDatedOnly(userId, _today());
}

@riverpod
Stream<List<AppTask>> somedayTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchSomeday(userId);
}

@riverpod
Stream<List<AppTask>> completedTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchCompleted(userId);
}

@riverpod
Stream<List<AppTask>> allTasksDueToday(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchAllDueOn(userId, _today());
}

/// §14.5: one range query per visible calendar period.
@riverpod
Stream<List<AppTask>> tasksDueInRange(Ref ref, CivilDate from, CivilDate through) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchDueInRange(userId, from, through);
}

@riverpod
Stream<List<AppTask>> recentlyCreatedTasks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(taskRepositoryProvider).watchRecentlyCreated(userId);
}

@riverpod
Stream<AppTask?> taskById(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).watchById(taskId);
}

@riverpod
Stream<List<AppSubtask>> subtasksOf(Ref ref, String taskId) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(taskId);
}
