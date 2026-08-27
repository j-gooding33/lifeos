import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';

AppGoal _okGoal(Result<AppGoal, Failure> result) =>
    result.when(ok: (g) => g, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late GoalRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GoalRepository(GoalDao(database));
  });

  tearDown(() => database.close());

  test('create then watchAll/watchById round-trips every field (§12.2)', () async {
    final created = await repository.createGoal(
      userId: 'u1',
      title: 'Read 20 books',
      type: GoalType.count,
      targetValue: 20,
      unit: 'books',
      startDate: const CivilDate(2026, 1, 1),
      endDate: const CivilDate(2026, 12, 31),
      colour: 'goals',
    );
    final goal = _okGoal(created);
    expect(goal.currentValue, 0);
    expect(goal.status, GoalStatus.active);

    final all = await repository.watchAll('u1').first;
    expect(all, hasLength(1));
    expect(all.single.title, 'Read 20 books');
    expect(all.single.unit, 'books');

    final byId = await repository.watchById(goal.id).first;
    expect(byId!.targetValue, 20);
  });

  test('addContribution increments currentValue and is auditable (§12.4)', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Watch films', type: GoalType.count, targetValue: 10));

    await repository.addContribution(
      goalId: goal.id,
      sourceType: 'libraryItem',
      sourceId: 'film1',
      value: 1,
      date: const CivilDate(2026, 3, 1),
    );
    final reloaded = await repository.watchById(goal.id).first;
    expect(reloaded!.currentValue, 1);

    final contributions = await repository.watchContributions(goal.id).first;
    expect(contributions, hasLength(1));
    expect(contributions.single.sourceId, 'film1');
  });

  test('addContribution deduplicates on (goalId, sourceType, sourceId) — §12.5 double counting', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Watch films', type: GoalType.count, targetValue: 10));

    await repository.addContribution(goalId: goal.id, sourceType: 'occurrence', sourceId: 'occ1', value: 1, date: const CivilDate(2026, 3, 1));
    await repository.addContribution(goalId: goal.id, sourceType: 'occurrence', sourceId: 'occ1', value: 1, date: const CivilDate(2026, 3, 1));

    final reloaded = await repository.watchById(goal.id).first;
    expect(reloaded!.currentValue, 1);
    expect(await repository.watchContributions(goal.id).first, hasLength(1));
  });

  test('reverseContribution decrements exactly the value it added and removes the row', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Watch films', type: GoalType.count, targetValue: 10));
    await repository.addContribution(goalId: goal.id, sourceType: 'occurrence', sourceId: 'occ1', value: 3, date: const CivilDate(2026, 3, 1));

    await repository.reverseContribution(goalId: goal.id, sourceType: 'occurrence', sourceId: 'occ1');

    final reloaded = await repository.watchById(goal.id).first;
    expect(reloaded!.currentValue, 0);
    expect(await repository.watchContributions(goal.id).first, isEmpty);
  });

  test('reverseContribution for a source that never contributed is a no-op', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Watch films', type: GoalType.count, targetValue: 10));
    final result = await repository.reverseContribution(goalId: goal.id, sourceType: 'occurrence', sourceId: 'never');
    expect(result.isOk, true);
    final reloaded = await repository.watchById(goal.id).first;
    expect(reloaded!.currentValue, 0);
  });

  test('addManualLog logs a contribution with its own unique source id', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Save money', type: GoalType.currency, targetValue: 500));
    await repository.addManualLog(goal.id, 50, const CivilDate(2026, 3, 1));
    await repository.addManualLog(goal.id, 25, const CivilDate(2026, 3, 2));

    final reloaded = await repository.watchById(goal.id).first;
    expect(reloaded!.currentValue, 75);
    expect(await repository.watchContributions(goal.id).first, hasLength(2));
  });

  test('milestones: save, complete, and delete round-trip', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Learn Spanish', type: GoalType.milestone));
    await repository.saveMilestone(goalId: goal.id, title: 'A1');
    final milestones = await repository.watchMilestones(goal.id).first;
    expect(milestones, hasLength(1));
    expect(milestones.single.isCompleted, false);

    await repository.setMilestoneCompleted(milestones.single, completed: true);
    final updated = await repository.watchMilestones(goal.id).first;
    expect(updated.single.isCompleted, true);

    await repository.deleteMilestone(updated.single.id);
    expect(await repository.watchMilestones(goal.id).first, isEmpty);
  });

  test('deleteGoal is a soft delete: it disappears from watchAll and watchById', () async {
    final goal = _okGoal(await repository.createGoal(userId: 'u1', title: 'Temporary', type: GoalType.boolean));
    await repository.deleteGoal(goal.id);
    expect(await repository.watchAll('u1').first, isEmpty);
    expect(await repository.watchById(goal.id).first, isNull);
  });
}
