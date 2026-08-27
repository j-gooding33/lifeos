import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) {
  return TaskRepository(TaskDao(ref.watch(appDatabaseProvider)));
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
