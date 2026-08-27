import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/subtasks_table.dart';
import 'package:life_os/data/local/tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks, Subtasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Due today or earlier, not completed (§10.3's Today/Overdue segments
  /// share this query — the UI splits "today" from "overdue" by comparing
  /// each row's `dueDate` to `today` itself, not with two queries).
  Stream<List<Task>> watchDueOnOrBefore(String userId, String today) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.completedAt.isNull() &
            t.dueDate.isSmallerOrEqualValue(today),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    return query.watch();
  }

  /// Future-dated tasks *and* undated ones (§10.3's "Upcoming" must not
  /// silently drop tasks with no date — see DECISIONS.md). Dated rows sort
  /// first by date; undated rows follow, by `sortIndex`.
  Stream<List<Task>> watchUpcoming(String userId, String afterDate) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.completedAt.isNull() &
            (t.dueDate.isNull() | t.dueDate.isBiggerThanValue(afterDate)),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.dueDate.isNull()),
        (t) => OrderingTerm.asc(t.dueDate),
        (t) => OrderingTerm.asc(t.sortIndex),
      ]);
    return query.watch();
  }

  /// Strictly future-dated, excluding undated tasks — the Today tab's
  /// "beyond today" section needs undated and future-dated tasks as two
  /// separately-ordered groups (undated first), so it can't use
  /// [watchUpcoming]'s combined ordering. See `task_providers.dart`.
  Stream<List<Task>> watchFutureDatedOnly(String userId, String afterDate) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.completedAt.isNull() &
            t.dueDate.isBiggerThanValue(afterDate),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    return query.watch();
  }

  /// "Someday" — no date at all (§10.3).
  Stream<List<Task>> watchNoDate(String userId) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.completedAt.isNull() &
            t.dueDate.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]);
    return query.watch();
  }

  /// Every task due exactly [date], done or not — used for Home's "6/9"
  /// completion count (§5.2), which needs the denominator too, not just
  /// the pending items the Today view shows.
  Stream<List<Task>> watchAllDueOn(String userId, String date) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.dueDate.equals(date),
      );
    return query.watch();
  }

  /// One range query per visible calendar period (§14.5), not one per cell.
  Stream<List<Task>> watchDueInRange(
    String userId,
    String from,
    String through,
  ) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.dueDate.isBiggerOrEqualValue(from) &
            t.dueDate.isSmallerOrEqualValue(through),
      );
    return query.watch();
  }

  Stream<List<Task>> watchRecentlyCreated(String userId, {int limit = 5}) {
    final query = select(tasks)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<Task>> watchCompletedSince(String userId, int sinceEpochMs) {
    final query = select(tasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.completedAt.isBiggerOrEqualValue(sinceEpochMs),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch();
  }

  Future<Task?> getById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Task?> watchById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> upsert(TasksCompanion entry) =>
      into(tasks).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(deletedAt: Value(now)),
      );

  /// §11.3's Project detail Tasks section, grouped To do/Done by the
  /// caller from one stream.
  Stream<List<Task>> watchByProjectId(String projectId) {
    final query = select(tasks)
      ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]);
    return query.watch();
  }

  /// §11.4's "delete 12 tasks too" choice.
  Future<void> softDeleteByProjectId(String projectId, int now) =>
      (update(tasks)..where((t) => t.projectId.equals(projectId))).write(
        TasksCompanion(deletedAt: Value(now)),
      );

  /// §11.4's "move them to no project" choice.
  Future<void> clearProjectId(String projectId) =>
      (update(tasks)..where((t) => t.projectId.equals(projectId))).write(
        const TasksCompanion(projectId: Value(null)),
      );

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    final query = select(subtasks)
      ..where((s) => s.taskId.equals(taskId) & s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.asc(s.sortIndex)]);
    return query.watch();
  }

  Future<void> upsertSubtask(SubtasksCompanion entry) =>
      into(subtasks).insertOnConflictUpdate(entry);

  Future<void> deleteSubtask(String id, int now) =>
      (update(subtasks)..where((s) => s.id.equals(id))).write(
        SubtasksCompanion(deletedAt: Value(now)),
      );
}
