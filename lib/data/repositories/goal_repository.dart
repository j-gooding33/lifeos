import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:uuid/uuid.dart';

/// §12. Goals — "the connective tissue of the app" (§12.4), though this
/// pass wires only the Plan-completion row of that table; see
/// DECISIONS.md for what's deferred (films/books/tasks/expenses) and why.
class GoalRepository {
  GoalRepository(this._dao);

  final GoalDao _dao;

  Stream<List<AppGoal>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Stream<AppGoal?> watchById(String id) => _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));

  Future<Result<AppGoal, Failure>> createGoal({
    required String userId,
    required String title,
    required GoalType type,
    String? description,
    double? targetValue,
    String? unit,
    CivilDate? startDate,
    CivilDate? endDate,
    String? colour,
    String? icon,
  }) async {
    try {
      final goal = AppGoal(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        type: type,
        description: description,
        targetValue: targetValue,
        unit: unit,
        startDate: startDate,
        endDate: endDate,
        colour: colour,
        icon: icon,
      );
      await _save(goal);
      return Ok(goal);
    } on Object catch (e) {
      return Err(DatabaseFailure('createGoal failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateGoal(AppGoal goal) async {
    try {
      await _save(goal);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateGoal failed: $e'));
    }
  }

  Future<Result<void, Failure>> setStatus(String id, GoalStatus status) async {
    try {
      await _dao.setStatus(id, status.name, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setStatus failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteGoal(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteGoal failed: $e'));
    }
  }

  Stream<List<AppGoalContribution>> watchContributions(String goalId) {
    return _dao.watchContributions(goalId).map((rows) => rows.map(_contributionToDomain).toList());
  }

  /// §12.4: every increment is a contribution row, and `currentValue` only
  /// ever moves alongside one. §12.5 "double counting": deduplicates on
  /// `(goalId, sourceType, sourceId)` — completing the same occurrence
  /// twice (e.g. a duplicate event) is a no-op, not a double-increment.
  Future<Result<void, Failure>> addContribution({
    required String goalId,
    required String sourceType,
    required String sourceId,
    required double value,
    required CivilDate date,
  }) async {
    try {
      final existing = await _dao.findContribution(goalId, sourceType, sourceId);
      if (existing != null) return const Ok(null);

      final goalRow = await _dao.getById(goalId);
      if (goalRow == null) return Err(NotFoundFailure('Goal $goalId not found'));

      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.insertContribution(
        db.GoalContributionsCompanion.insert(
          id: const Uuid().v4(),
          goalId: goalId,
          sourceType: sourceType,
          sourceId: sourceId,
          value: value,
          date: date.toIso(),
          createdAt: Value(now),
        ),
      );
      await _dao.setCurrentValue(goalId, goalRow.currentValue + value, now);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('addContribution failed: $e'));
    }
  }

  /// §12.4: "un-completing a film decrements exactly the contribution it
  /// created" — finds the one contribution row this source wrote, deletes
  /// it, and reverses its exact value. A no-op if that source never
  /// actually contributed (nothing to reverse).
  Future<Result<void, Failure>> reverseContribution({
    required String goalId,
    required String sourceType,
    required String sourceId,
  }) async {
    try {
      final existing = await _dao.findContribution(goalId, sourceType, sourceId);
      if (existing == null) return const Ok(null);

      final goalRow = await _dao.getById(goalId);
      if (goalRow == null) return Err(NotFoundFailure('Goal $goalId not found'));

      await _dao.deleteContribution(existing.id);
      await _dao.setCurrentValue(goalId, goalRow.currentValue - existing.value, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('reverseContribution failed: $e'));
    }
  }

  /// §12.4's "Manual log" row — a contribution with no real domain
  /// source, keyed on its own generated id so it never dedupes against
  /// anything else.
  Future<Result<void, Failure>> addManualLog(String goalId, double value, CivilDate date) {
    return addContribution(goalId: goalId, sourceType: 'manual', sourceId: const Uuid().v4(), value: value, date: date);
  }

  Stream<List<AppGoalMilestone>> watchMilestones(String goalId) {
    return _dao.watchMilestones(goalId).map((rows) => rows.map(_milestoneToDomain).toList());
  }

  Future<Result<void, Failure>> saveMilestone({
    required String goalId,
    required String title,
    String? id,
    double? targetValue,
    CivilDate? dueDate,
  }) async {
    try {
      await _dao.upsertMilestone(
        db.GoalMilestonesCompanion(
          id: Value(id ?? const Uuid().v4()),
          goalId: Value(goalId),
          title: Value(title),
          targetValue: Value(targetValue),
          dueDate: Value(dueDate?.toIso()),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveMilestone failed: $e'));
    }
  }

  Future<Result<void, Failure>> setMilestoneCompleted(AppGoalMilestone milestone, {required bool completed}) async {
    try {
      await _dao.upsertMilestone(
        db.GoalMilestonesCompanion(
          id: Value(milestone.id),
          goalId: Value(milestone.goalId),
          title: Value(milestone.title),
          targetValue: Value(milestone.targetValue),
          dueDate: Value(milestone.dueDate?.toIso()),
          completedAt: Value(completed ? DateTime.now().millisecondsSinceEpoch : null),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setMilestoneCompleted failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteMilestone(String id) async {
    try {
      await _dao.deleteMilestone(id);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteMilestone failed: $e'));
    }
  }

  Future<void> _save(AppGoal goal) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.GoalsCompanion(
        id: Value(goal.id),
        userId: Value(goal.userId),
        title: Value(goal.title),
        description: Value(goal.description),
        type: Value(goal.type.name),
        targetValue: Value(goal.targetValue),
        currentValue: Value(goal.currentValue),
        unit: Value(goal.unit),
        startDate: Value(goal.startDate?.toIso()),
        endDate: Value(goal.endDate?.toIso()),
        colour: Value(goal.colour),
        icon: Value(goal.icon),
        status: Value(goal.status.name),
        createdAt: Value(goal.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppGoal> _toDomainList(List<db.Goal> rows) => rows.map(_toDomain).toList();

  AppGoal _toDomain(db.Goal row) {
    return AppGoal(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      type: GoalType.values.firstWhere((t) => t.name == row.type, orElse: () => GoalType.boolean),
      targetValue: row.targetValue,
      currentValue: row.currentValue,
      unit: row.unit,
      startDate: row.startDate == null ? null : CivilDate.parse(row.startDate!),
      endDate: row.endDate == null ? null : CivilDate.parse(row.endDate!),
      colour: row.colour,
      icon: row.icon,
      status: GoalStatus.values.firstWhere((s) => s.name == row.status, orElse: () => GoalStatus.active),
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }

  AppGoalContribution _contributionToDomain(db.GoalContribution row) {
    return AppGoalContribution(
      id: row.id,
      goalId: row.goalId,
      sourceType: row.sourceType,
      sourceId: row.sourceId,
      value: row.value,
      date: CivilDate.parse(row.date),
    );
  }

  AppGoalMilestone _milestoneToDomain(db.GoalMilestone row) {
    return AppGoalMilestone(
      id: row.id,
      goalId: row.goalId,
      title: row.title,
      targetValue: row.targetValue,
      dueDate: row.dueDate == null ? null : CivilDate.parse(row.dueDate!),
      completedAt: row.completedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
    );
  }
}
