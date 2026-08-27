import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/features/tasks/application/goal_projection.dart';

AppGoal _goal({
  double? targetValue,
  double currentValue = 0,
  CivilDate? startDate,
  CivilDate? endDate,
  GoalStatus status = GoalStatus.active,
}) {
  return AppGoal(
    id: 'g1',
    userId: 'u1',
    title: 'Read 20 books',
    type: GoalType.count,
    targetValue: targetValue,
    currentValue: currentValue,
    startDate: startDate,
    endDate: endDate,
    status: status,
  );
}

void main() {
  const today = CivilDate(2026, 8, 28);

  test('a goal with no target has no on-track judgement, just the raw count', () {
    final projection = computeGoalProjection(_goal(currentValue: 5), today: today);
    expect(projection.onTrack, isNull);
    expect(projection.summary, contains('5'));
  });

  test('a reached goal reports Reached regardless of the end date', () {
    final projection = computeGoalProjection(_goal(targetValue: 20, currentValue: 22), today: today);
    expect(projection.onTrack, isTrue);
    expect(projection.summary, contains('Reached'));
  });

  test('an ended, unmet goal reports "Ended at", not a judgement on the current rate', () {
    final projection = computeGoalProjection(
      _goal(targetValue: 20, currentValue: 14, startDate: const CivilDate(2026, 1, 1), endDate: const CivilDate(2026, 6, 1)),
      today: today,
    );
    expect(projection.onTrack, isFalse);
    expect(projection.summary, contains('Ended at'));
  });

  test('on-track when the current rate reaches the target before the deadline', () {
    // Started 100 days ago at 1/day average, target 200, 200 days left — easily on track.
    final projection = computeGoalProjection(
      _goal(targetValue: 200, currentValue: 100, startDate: today.addDays(-100), endDate: today.addDays(200)),
      today: today,
    );
    expect(projection.onTrack, isTrue);
    expect(projection.summary, contains('On track'));
  });

  test('off track when the current rate will not reach the target before the deadline', () {
    // 100 days in at 0.1/day average, target 200, only 5 days left — will clearly miss.
    final projection = computeGoalProjection(
      _goal(targetValue: 200, currentValue: 10, startDate: today.addDays(-100), endDate: today.addDays(5)),
      today: today,
    );
    expect(projection.onTrack, isFalse);
    expect(projection.summary, contains('Off track'));
  });

  test('no progress logged yet with a deadline is honestly off track, not a divide-by-zero', () {
    final projection = computeGoalProjection(
      _goal(targetValue: 200, startDate: today.addDays(-10), endDate: today.addDays(30)),
      today: today,
    );
    expect(projection.onTrack, isFalse);
    expect(projection.summary, contains('no progress'));
  });
}
