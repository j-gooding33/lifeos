/// §10.2. `none` sorts and displays as no priority at all — never implied
/// by absence, since that's indistinguishable from "not set yet."
enum TaskPriority {
  none,
  low,
  medium,
  high;

  static TaskPriority fromValue(int value) =>
      TaskPriority.values[value.clamp(0, 3)];
}

class AppSubtask {
  const AppSubtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.completedAt,
    this.sortIndex = 0,
  });

  final String id;
  final String taskId;
  final String title;
  final DateTime? completedAt;
  final double sortIndex;

  bool get isCompleted => completedAt != null;
}

/// The domain-level task — feature code sees this, never Drift's
/// generated `Task` row class (CLAUDE.md: domain models never leak Drift
/// types into features/).
class AppTask {
  AppTask({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.none,
    this.categoryId,
    this.projectId,
    this.goalId,
    this.recurrenceRule,
    this.sortIndex = 0,
    this.completedAt,
    this.subtasks = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? notes;

  /// Civil date `YYYY-MM-DD` (§9.1) — never a `DateTime`.
  final String? dueDate;

  /// Wall time `HH:mm` (§9.1).
  final String? dueTime;
  final TaskPriority priority;
  final String? categoryId;
  final String? projectId;
  final String? goalId;
  final String? recurrenceRule;
  final double sortIndex;
  final DateTime? completedAt;
  final List<AppSubtask> subtasks;

  /// Set once, at construction, and carried through every `copyWith` — a
  /// re-save must never bump this back to "now" (that's what `updatedAt`
  /// is for, handled at the repository layer).
  final DateTime createdAt;

  bool get isCompleted => completedAt != null;
  bool get isRepeating => recurrenceRule != null;

  AppTask copyWith({
    String? title,
    String? notes,
    String? dueDate,
    String? dueTime,
    TaskPriority? priority,
    String? categoryId,
    String? projectId,
    String? goalId,
    String? recurrenceRule,
    double? sortIndex,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool clearDueDate = false,
  }) {
    return AppTask(
      id: id,
      userId: userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      projectId: projectId ?? this.projectId,
      goalId: goalId ?? this.goalId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      sortIndex: sortIndex ?? this.sortIndex,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      subtasks: subtasks,
      createdAt: createdAt,
    );
  }
}
