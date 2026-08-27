import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/goal_contributions_table.dart';
import 'package:life_os/data/local/tables/goal_milestones_table.dart';
import 'package:life_os/data/local/tables/goals_table.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [Goals, GoalContributions, GoalMilestones])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Stream<List<Goal>> watchAll(String userId) {
    final query = select(goals)
      ..where((g) => g.userId.equals(userId) & g.deletedAt.isNull())
      ..orderBy([(g) => OrderingTerm.asc(g.title)]);
    return query.watch();
  }

  Stream<Goal?> watchById(String id) {
    final query = select(goals)..where((g) => g.id.equals(id) & g.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<Goal?> getById(String id) => (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<void> upsert(GoalsCompanion entry) => into(goals).insertOnConflictUpdate(entry);

  Future<void> setCurrentValue(String id, double currentValue, int now) =>
      (update(goals)..where((g) => g.id.equals(id))).write(
        GoalsCompanion(currentValue: Value(currentValue), updatedAt: Value(now)),
      );

  Future<void> setStatus(String id, String status, int now) =>
      (update(goals)..where((g) => g.id.equals(id))).write(
        GoalsCompanion(status: Value(status), updatedAt: Value(now)),
      );

  Future<void> softDelete(String id, int now) =>
      (update(goals)..where((g) => g.id.equals(id))).write(GoalsCompanion(deletedAt: Value(now)));

  Stream<List<GoalContribution>> watchContributions(String goalId) {
    final query = select(goalContributions)
      ..where((c) => c.goalId.equals(goalId))
      ..orderBy([(c) => OrderingTerm.desc(c.date)]);
    return query.watch();
  }

  Future<GoalContribution?> findContribution(String goalId, String sourceType, String sourceId) {
    return (select(goalContributions)
          ..where((c) => c.goalId.equals(goalId) & c.sourceType.equals(sourceType) & c.sourceId.equals(sourceId)))
        .getSingleOrNull();
  }

  Future<void> insertContribution(GoalContributionsCompanion entry) => into(goalContributions).insert(entry);

  Future<void> deleteContribution(String id) => (delete(goalContributions)..where((c) => c.id.equals(id))).go();

  Stream<List<GoalMilestone>> watchMilestones(String goalId) {
    final query = select(goalMilestones)
      ..where((m) => m.goalId.equals(goalId))
      ..orderBy([(m) => OrderingTerm.asc(m.sortIndex)]);
    return query.watch();
  }

  Future<void> upsertMilestone(GoalMilestonesCompanion entry) => into(goalMilestones).insertOnConflictUpdate(entry);

  Future<void> deleteMilestone(String id) => (delete(goalMilestones)..where((m) => m.id.equals(id))).go();
}
