import 'package:life_os/core/scheduling/civil_date.dart';

/// §12.2. `milestone` and `boolean` goals have no meaningful
/// `targetValue`/`currentValue` arithmetic — a milestone goal's progress is
/// "milestones completed / total," a boolean goal's is 0 or 1.
enum GoalType { count, quantity, duration, currency, milestone, boolean }

enum GoalStatus { active, ended, archived }

/// A measurable outcome over a period (§12.1) — "the layer that gives
/// Plans and Tasks a reason." `currentValue` is a cached running total,
/// never touched except alongside a `AppGoalContribution` row (§12.4: an
/// auditable, reversible increment) — this model doesn't enforce that
/// itself, `GoalRepository` does.
class AppGoal {
  AppGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.description,
    this.targetValue,
    this.currentValue = 0,
    this.unit,
    this.startDate,
    this.endDate,
    this.colour,
    this.icon,
    this.status = GoalStatus.active,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? description;
  final GoalType type;
  final double? targetValue;
  final double currentValue;
  final String? unit;
  final CivilDate? startDate;
  final CivilDate? endDate;
  final String? colour;
  final String? icon;
  final GoalStatus status;
  final DateTime createdAt;

  bool get isReached => targetValue != null && currentValue >= targetValue!;
  bool get isArchived => status == GoalStatus.archived;

  double? get progress {
    if (targetValue == null || targetValue == 0) return null;
    return (currentValue / targetValue!).clamp(0, double.infinity).toDouble();
  }

  AppGoal copyWith({
    String? title,
    String? description,
    GoalType? type,
    double? targetValue,
    bool clearTargetValue = false,
    double? currentValue,
    String? unit,
    CivilDate? startDate,
    CivilDate? endDate,
    bool clearEndDate = false,
    String? colour,
    String? icon,
    GoalStatus? status,
  }) {
    return AppGoal(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: clearTargetValue ? null : (targetValue ?? this.targetValue),
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      colour: colour ?? this.colour,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

/// §12.4. One auditable, reversible increment. `sourceType`/`sourceId`
/// identify what caused it (e.g. `'occurrence'`/an occurrence id) — the
/// `(goalId, sourceType, sourceId)` unique index (`idx_contrib_dedupe`,
/// migrated since M4) is what makes completing the same occurrence twice
/// a no-op rather than double-counted.
class AppGoalContribution {
  const AppGoalContribution({
    required this.id,
    required this.goalId,
    required this.sourceType,
    required this.sourceId,
    required this.value,
    required this.date,
  });

  final String id;
  final String goalId;
  final String sourceType;
  final String sourceId;
  final double value;
  final CivilDate date;
}

class AppGoalMilestone {
  const AppGoalMilestone({
    required this.id,
    required this.goalId,
    this.title,
    this.targetValue,
    this.dueDate,
    this.completedAt,
  });

  final String id;
  final String goalId;
  final String? title;
  final double? targetValue;
  final CivilDate? dueDate;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
}
