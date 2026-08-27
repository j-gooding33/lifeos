import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart' show MissedPolicy;
import 'package:life_os/core/scheduling/recurrence_rule.dart';

/// §7.2's `target` field — `{value, unit}`, e.g. "8 glasses" or "30
/// minutes". §13.2: a habit with `value > 1` renders a stepper and a
/// partial ring instead of a plain checkmark.
class PlanTarget {
  const PlanTarget({required this.value, required this.unit});

  factory PlanTarget.fromJson(Map<String, Object?> json) {
    return PlanTarget(value: (json['value']! as num).toDouble(), unit: json['unit']! as String);
  }

  final double value;
  final String unit;

  Map<String, Object?> toJson() => {'value': value, 'unit': unit};
}

/// §7.1, binding: habits are plans with `kind = habit` — there is no
/// separate habits engine.
enum PlanKind { plan, habit }

/// §9.4. `fixed` dates never move; `rolling` restarts the rhythm from
/// whenever the occurrence was actually completed.
enum ScheduleMode { fixed, rolling }

/// §8.1. `moved` isn't a separate value here — §8.4 step 1 sets a moved
/// occurrence's status to `pending` (with `originalDate` set), so "moved"
/// is a derived presentation state (`pending` + `originalDate != null`),
/// not a distinct one.
enum OccurrenceStatus { pending, completed, skipped, missed, cancelled }

/// §7.2. `rule.anchor` is the date the rhythm counts from; [startDate] is
/// the separate "first date the plan is active" field — occurrences the
/// rule would otherwise generate before [startDate] don't materialise.
class AppPlan {
  AppPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.rule,
    this.kind = PlanKind.plan,
    this.icon,
    this.colour,
    this.category,
    this.mediaType,
    CivilDate? startDate,
    this.endDate,
    this.endAfterCount,
    this.timeOfDay,
    this.durationMinutes,
    this.target,
    this.missedPolicy = MissedPolicy.markMissed,
    this.scheduleMode = ScheduleMode.fixed,
    this.pauseFrom,
    this.pauseUntil,
    this.goalId,
    this.notes,
    this.generationVersion = 1,
    this.archivedAt,
    DateTime? createdAt,
  }) : startDate = startDate ?? rule.anchor,
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final PlanKind kind;
  final String title;
  final String? icon;

  /// Domain colour name (e.g. `plans`) or an accent name — resolved by the
  /// presentation layer, never a raw hex value here.
  final String? colour;
  final String? category;
  final String? mediaType;
  final RecurrenceRule rule;
  final CivilDate startDate;
  final CivilDate? endDate;
  final int? endAfterCount;

  /// Wall time `HH:mm` (§9.1).
  final String? timeOfDay;
  final int? durationMinutes;
  final PlanTarget? target;
  final MissedPolicy missedPolicy;
  final ScheduleMode scheduleMode;
  final CivilDate? pauseFrom;
  final CivilDate? pauseUntil;
  final String? goalId;
  final String? notes;

  /// Bumped on every rule change (§9.7) so regenerated occurrences get
  /// fresh deterministic ids instead of colliding with the old series.
  final int generationVersion;
  final DateTime? archivedAt;
  final DateTime createdAt;

  bool get isHabit => kind == PlanKind.habit;
  bool get isArchived => archivedAt != null;

  bool isPausedOn(CivilDate date) {
    if (pauseFrom == null || pauseUntil == null) return false;
    return date.isAtOrAfter(pauseFrom!) && date.isAtOrBefore(pauseUntil!);
  }

  AppPlan copyWith({
    String? title,
    String? icon,
    String? colour,
    String? category,
    String? mediaType,
    RecurrenceRule? rule,
    CivilDate? startDate,
    CivilDate? endDate,
    bool clearEndDate = false,
    int? endAfterCount,
    bool clearEndAfterCount = false,
    String? timeOfDay,
    int? durationMinutes,
    PlanTarget? target,
    bool clearTarget = false,
    MissedPolicy? missedPolicy,
    ScheduleMode? scheduleMode,
    CivilDate? pauseFrom,
    CivilDate? pauseUntil,
    bool clearPause = false,
    String? goalId,
    String? notes,
    int? generationVersion,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return AppPlan(
      id: id,
      userId: userId,
      kind: kind,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      colour: colour ?? this.colour,
      category: category ?? this.category,
      mediaType: mediaType ?? this.mediaType,
      rule: rule ?? this.rule,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      endAfterCount: clearEndAfterCount
          ? null
          : (endAfterCount ?? this.endAfterCount),
      timeOfDay: timeOfDay ?? this.timeOfDay,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      target: clearTarget ? null : (target ?? this.target),
      missedPolicy: missedPolicy ?? this.missedPolicy,
      scheduleMode: scheduleMode ?? this.scheduleMode,
      pauseFrom: clearPause ? null : (pauseFrom ?? this.pauseFrom),
      pauseUntil: clearPause ? null : (pauseUntil ?? this.pauseUntil),
      goalId: goalId ?? this.goalId,
      notes: notes ?? this.notes,
      generationVersion: generationVersion ?? this.generationVersion,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      createdAt: createdAt,
    );
  }
}

/// §8.1. A real, individually editable row — never a computed view.
class AppOccurrence {
  const AppOccurrence({
    required this.id,
    required this.planId,
    required this.scheduledDate,
    this.scheduledTime,
    this.originalDate,
    this.status = OccurrenceStatus.pending,
    this.completedAt,
    this.valueAchieved,
    this.linkedEntityType,
    this.linkedEntityId,
    this.note,
    this.isException = false,
    this.generationVersion = 1,
  });

  final String id;
  final String planId;
  final CivilDate scheduledDate;
  final String? scheduledTime;
  final CivilDate? originalDate;
  final OccurrenceStatus status;
  final DateTime? completedAt;
  final double? valueAchieved;
  final String? linkedEntityType;
  final String? linkedEntityId;
  final String? note;
  final bool isException;
  final int generationVersion;

  bool get isCompleted => status == OccurrenceStatus.completed;
}

/// The Plan detail stats strip (§7.5): done / rate / streak / missed, plus
/// a 12-week completion heatmap.
class PlanStats {
  const PlanStats({
    required this.done,
    required this.rate,
    required this.streak,
    required this.bestStreak,
    required this.missed,
    required this.weeklyHeatmap,
  });

  final int done;

  /// 0.0–1.0. `done / (done + missed)`, ignoring cancelled/pending rows —
  /// a `skip`-policy plan's cancelled days count against neither side
  /// (§9.6: "nothing is counted").
  final double rate;
  final int streak;

  /// §13.2: "best streak" — the longest consecutive-completed run in this
  /// plan's whole history, not just the current one. Always `>= streak`.
  final int bestStreak;
  final int missed;

  /// Oldest week first, each 0.0–1.0 or null for "no occurrences that week".
  final List<double?> weeklyHeatmap;
}
