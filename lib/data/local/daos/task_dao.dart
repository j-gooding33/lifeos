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

  Stream<List<Task>> watchUpcoming(String userId, String afterDate) {
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
        (t) => t.userId.equals(userId) & t.deletedAt.isNull() & t.completedAt.isNull() & t.dueDate.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]);
    return query.watch();
  }

  /// Every task due exactly [date], done or not — used for Home's "6/9"
  /// completion count (§5.2), which needs the denominator too, not just
  /// the pending items the Today view shows.
  Stream<List<Task>> watchAllDueOn(String userId, String date) {
    final query = select(tasks)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull() & t.dueDate.equals(date));
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

  Future<void> upsert(TasksCompanion entry) => into(tasks).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(TasksCompanion(deletedAt: Value(now)));

  Stream<List<Subtask>> watchSubtasks(String taskId) {
    final query = select(subtasks)
      ..where((s) => s.taskId.equals(taskId) & s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.asc(s.sortIndex)]);
    return query.watch();
  }

  Future<void> upsertSubtask(SubtasksCompanion entry) => into(subtasks).insertOnConflictUpdate(entry);

  Future<void> deleteSubtask(String id, int now) => (update(
    subtasks,
  )..where((s) => s.id.equals(id))).write(SubtasksCompanion(deletedAt: Value(now)));
}
