import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/core/scheduling/recurrence_rule_json.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:uuid/uuid.dart';

/// §10. A repeating task (has a `recurrenceRule`) differs from a Plan: on
/// completion it creates the next instance immediately and the previous
/// one stays in history — it does not pre-materialise a calendar the way
/// Plans do (§10.2).
class TaskRepository {
  TaskRepository(this._dao, {RecurrenceEngine? engine})
    : _engine = engine ?? const RecurrenceEngine();

  final TaskDao _dao;
  final RecurrenceEngine _engine;

  Stream<List<AppTask>> watchToday(String userId, CivilDate today) {
    return _dao.watchDueOnOrBefore(userId, today.toIso()).map(_toDomainList);
  }

  Stream<List<AppTask>> watchOverdue(String userId, CivilDate today) {
    return _dao
        .watchDueOnOrBefore(userId, today.addDays(-1).toIso())
        .map(_toDomainList);
  }

  Stream<List<AppTask>> watchUpcoming(String userId, CivilDate today) {
    return _dao.watchUpcoming(userId, today.toIso()).map(_toDomainList);
  }

  Stream<List<AppTask>> watchFutureDatedOnly(String userId, CivilDate today) {
    return _dao.watchFutureDatedOnly(userId, today.toIso()).map(_toDomainList);
  }

  Stream<List<AppTask>> watchSomeday(String userId) {
    return _dao.watchNoDate(userId).map(_toDomainList);
  }

  Stream<List<AppTask>> watchAllDueOn(String userId, CivilDate date) {
    return _dao.watchAllDueOn(userId, date.toIso()).map(_toDomainList);
  }

  Stream<List<AppTask>> watchDueInRange(
    String userId,
    CivilDate from,
    CivilDate through,
  ) {
    return _dao
        .watchDueInRange(userId, from.toIso(), through.toIso())
        .map(_toDomainList);
  }

  Stream<List<AppTask>> watchRecentlyCreated(String userId, {int limit = 5}) {
    return _dao.watchRecentlyCreated(userId, limit: limit).map(_toDomainList);
  }

  Stream<AppTask?> watchById(String id) {
    return _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));
  }

  Stream<List<AppTask>> watchCompleted(
    String userId, {
    int retentionDays = 90,
  }) {
    final since = DateTime.now()
        .subtract(Duration(days: retentionDays))
        .millisecondsSinceEpoch;
    return _dao.watchCompletedSince(userId, since).map(_toDomainList);
  }

  Future<Result<AppTask, Failure>> createTask({
    required String userId,
    required String title,
    String? notes,
    String? dueDate,
    String? dueTime,
    TaskPriority priority = TaskPriority.none,
    String? projectId,
    String? recurrenceRule,
  }) async {
    try {
      final task = AppTask(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        notes: notes,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        projectId: projectId,
        recurrenceRule: recurrenceRule,
      );
      await _save(task);
      return Ok(task);
    } on Object catch (e) {
      return Err(DatabaseFailure('createTask failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateTask(AppTask task) async {
    try {
      await _save(task);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateTask failed: $e'));
    }
  }

  /// Returns the newly-created next instance when [task] repeats, so the
  /// caller can show "Next: 26 September" (§10.6).
  Future<Result<AppTask?, Failure>> completeTask(AppTask task) async {
    try {
      final now = DateTime.now();
      await _save(task.copyWith(completedAt: now));

      if (task.recurrenceRule == null || task.dueDate == null) {
        return const Ok(null);
      }

      final rule = recurrenceRuleFromJsonString(task.recurrenceRule!);
      final currentDue = CivilDate.parse(task.dueDate!);
      final nextDates = _engine.next(rule, currentDue, 1);
      if (nextDates.isEmpty) return const Ok(null);

      final next = AppTask(
        id: const Uuid().v4(),
        userId: task.userId,
        title: task.title,
        notes: task.notes,
        dueDate: nextDates.first.toIso(),
        dueTime: task.dueTime,
        priority: task.priority,
        categoryId: task.categoryId,
        projectId: task.projectId,
        goalId: task.goalId,
        recurrenceRule: task.recurrenceRule,
      );
      await _save(next);
      return Ok(next);
    } on Object catch (e) {
      return Err(DatabaseFailure('completeTask failed: $e'));
    }
  }

  Future<Result<void, Failure>> uncompleteTask(AppTask task) async {
    try {
      await _save(task.copyWith(clearCompletedAt: true));
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('uncompleteTask failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteTask(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteTask failed: $e'));
    }
  }

  Stream<List<AppSubtask>> watchSubtasks(String taskId) {
    return _dao
        .watchSubtasks(taskId)
        .map(
          (rows) => rows
              .map(
                (r) => AppSubtask(
                  id: r.id,
                  taskId: r.taskId,
                  title: r.title,
                  completedAt: r.completedAt == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(r.completedAt!),
                  sortIndex: r.sortIndex ?? 0,
                ),
              )
              .toList(),
        );
  }

  Future<Result<void, Failure>> addSubtask(String taskId, String title) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertSubtask(
        db.SubtasksCompanion.insert(
          id: const Uuid().v4(),
          taskId: taskId,
          title: title,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('addSubtask failed: $e'));
    }
  }

  Future<Result<void, Failure>> setSubtaskCompleted(
    AppSubtask subtask, {
    required bool completed,
  }) async {
    try {
      await _dao.upsertSubtask(
        db.SubtasksCompanion(
          id: Value(subtask.id),
          taskId: Value(subtask.taskId),
          title: Value(subtask.title),
          completedAt: Value(
            completed ? DateTime.now().millisecondsSinceEpoch : null,
          ),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setSubtaskCompleted failed: $e'));
    }
  }

  Future<void> _save(AppTask task) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.TasksCompanion(
        id: Value(task.id),
        userId: Value(task.userId),
        title: Value(task.title),
        notes: Value(task.notes),
        dueDate: Value(task.dueDate),
        dueTime: Value(task.dueTime),
        priority: Value(task.priority.index),
        categoryId: Value(task.categoryId),
        projectId: Value(task.projectId),
        goalId: Value(task.goalId),
        recurrenceRule: Value(task.recurrenceRule),
        sortIndex: Value(task.sortIndex),
        completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
        createdAt: Value(task.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppTask> _toDomainList(List<db.Task> rows) =>
      rows.map(_toDomain).toList();

  AppTask _toDomain(db.Task row) {
    return AppTask(
      id: row.id,
      userId: row.userId,
      title: row.title,
      notes: row.notes,
      dueDate: row.dueDate,
      dueTime: row.dueTime,
      priority: TaskPriority.fromValue(row.priority),
      categoryId: row.categoryId,
      projectId: row.projectId,
      goalId: row.goalId,
      recurrenceRule: row.recurrenceRule,
      sortIndex: row.sortIndex,
      completedAt: row.completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
      createdAt: row.createdAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }
}
