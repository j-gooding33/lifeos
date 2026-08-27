import 'package:life_os/core/scheduling/civil_date.dart';

enum ProjectStatus { active, onHold, done, archived }

/// A longer-running effort (§11): a container for tasks with a shared
/// outcome, progress and deadline. Progress is deliberately not a field
/// here — §11.2 is explicit that it's derived (`completedTasks /
/// totalTasks`), never stored, so it's computed by the UI from
/// `TaskRepository.watchByProjectId`, not cached on this model.
class AppProject {
  AppProject({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.colour,
    this.icon,
    this.deadline,
    this.goalId,
    this.status = ProjectStatus.active,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? colour;
  final String? icon;
  final CivilDate? deadline;
  final String? goalId;
  final ProjectStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isArchived => status == ProjectStatus.archived;

  AppProject copyWith({
    String? title,
    String? description,
    String? colour,
    String? icon,
    CivilDate? deadline,
    bool clearDeadline = false,
    String? goalId,
    ProjectStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return AppProject(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      colour: colour ?? this.colour,
      icon: icon ?? this.icon,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      goalId: goalId ?? this.goalId,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt,
    );
  }
}
