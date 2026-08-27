import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';

/// §12.3: "The projection is honest arithmetic, not encouragement: if the
/// current rate will miss the target it says so plainly." Pure — no
/// Flutter, no database — so the arithmetic itself is directly testable.
class GoalProjection {
  const GoalProjection({required this.onTrack, required this.summary});

  /// Null when there isn't enough information to project at all (no
  /// target, no start date, or the goal has already ended) — the caller
  /// shows the summary without an on-track/off-track judgement then.
  final bool? onTrack;
  final String summary;
}

GoalProjection computeGoalProjection(AppGoal goal, {required CivilDate today}) {
  final target = goal.targetValue;
  final start = goal.startDate;
  final end = goal.endDate;

  if (goal.isReached) {
    return GoalProjection(onTrack: true, summary: 'Reached — ${_formatValue(goal.currentValue)} of ${_formatValue(target ?? 0)}.');
  }
  if (target == null || target <= 0) {
    return GoalProjection(onTrack: null, summary: '${_formatValue(goal.currentValue)} so far.');
  }
  if (end != null && today.isAfter(end)) {
    return GoalProjection(onTrack: false, summary: 'Ended at ${_formatValue(goal.currentValue)} of ${_formatValue(target)}.');
  }
  if (start == null || !today.isAfter(start)) {
    return GoalProjection(onTrack: null, summary: '${_formatValue(goal.currentValue)} of ${_formatValue(target)} so far.');
  }

  final daysElapsed = CivilDate.daysBetween(start, today);
  final ratePerDay = goal.currentValue / daysElapsed;
  final remaining = target - goal.currentValue;

  if (end == null) {
    return GoalProjection(
      onTrack: null,
      summary: '${_formatValue(remaining)} to go, averaging ${_formatRate(ratePerDay)} a day.',
    );
  }

  final daysLeft = CivilDate.daysBetween(today, end);
  if (daysLeft <= 0) {
    return GoalProjection(onTrack: false, summary: '${_formatValue(remaining)} to go and the deadline has passed.');
  }
  if (ratePerDay <= 0) {
    return GoalProjection(onTrack: false, summary: '${_formatValue(remaining)} to go, $daysLeft days left — no progress logged yet.');
  }

  final daysNeeded = remaining / ratePerDay;
  final onTrack = daysNeeded <= daysLeft;
  final monthsLeft = (daysLeft / 30).round().clamp(0, daysLeft);
  return GoalProjection(
    onTrack: onTrack,
    summary: onTrack
        ? 'On track — ${_formatValue(remaining)} to go, $monthsLeft month${monthsLeft == 1 ? '' : 's'} left, averaging ${_formatRate(ratePerDay * 30)} a month.'
        : 'Off track at this rate — ${_formatValue(remaining)} to go with only $daysLeft days left.',
  );
}

String _formatValue(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

String _formatRate(double perPeriod) => perPeriod == perPeriod.roundToDouble() ? perPeriod.toInt().toString() : perPeriod.toStringAsFixed(1);
