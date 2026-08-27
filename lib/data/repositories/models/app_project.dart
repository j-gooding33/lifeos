/// A longer-running effort (§11) — deliberately thin until a real Projects
/// screen exists (`Routes.projects` is still a placeholder); onboarding
/// (item 8) is the only writer today.
class AppProject {
  AppProject({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final DateTime createdAt;
}
