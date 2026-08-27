import 'package:life_os/core/scheduling/civil_date.dart';

enum MissedPolicy { skip, markMissed, rollForward }

enum SweepOutcome { cancelled, missed, rolledForward, unchanged }

class PendingOccurrence {
  const PendingOccurrence(this.id, this.planId, this.scheduledDate);
  final String id;
  final String planId;
  final CivilDate scheduledDate;
}

class SweepResult {
  const SweepResult(this.occurrenceId, this.outcome, {this.newDate});
  final String occurrenceId;
  final SweepOutcome outcome;
  final CivilDate? newDate;
}

/// §9.6. Applied to occurrences whose `scheduledDate < today` and
/// `status == pending`. Pure — the caller writes the resulting status/date
/// changes to the database.
class MissedSweep {
  const MissedSweep();

  static const maxRollForwardsPerPlanPerDay = 3;

  List<SweepResult> apply({
    required List<PendingOccurrence> pastPending,
    required CivilDate today,
    required MissedPolicy policy,
  }) {
    switch (policy) {
      case MissedPolicy.skip:
        return [for (final o in pastPending) SweepResult(o.id, SweepOutcome.cancelled)];
      case MissedPolicy.markMissed:
        return [for (final o in pastPending) SweepResult(o.id, SweepOutcome.missed)];
      case MissedPolicy.rollForward:
        return _rollForward(pastPending, today);
    }
  }

  List<SweepResult> _rollForward(List<PendingOccurrence> pastPending, CivilDate today) {
    final results = <SweepResult>[];
    final rolledCountByPlan = <String, int>{};
    // Oldest first, so a long absence rolls the earliest misses, not the
    // most recent ones, into today.
    final sorted = [...pastPending]..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    for (final o in sorted) {
      final rolledSoFar = rolledCountByPlan[o.planId] ?? 0;
      if (rolledSoFar >= maxRollForwardsPerPlanPerDay) {
        results.add(SweepResult(o.id, SweepOutcome.missed));
        continue;
      }
      rolledCountByPlan[o.planId] = rolledSoFar + 1;
      results.add(SweepResult(o.id, SweepOutcome.rolledForward, newDate: today));
    }
    return results;
  }
}
