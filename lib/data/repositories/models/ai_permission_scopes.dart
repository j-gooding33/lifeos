/// §19.2. One master switch, a separate write switch, and a per-domain
/// read scope. Journal and finance default off — every other domain
/// defaults on. Inert today (see DECISIONS.md's AI decision): nothing
/// reads these yet, since there's no AI backend to gate.
class AiPermissionScopes {
  const AiPermissionScopes({
    this.enabled = false,
    this.canWrite = true,
    this.tasks = true,
    this.plans = true,
    this.habits = true,
    this.goals = true,
    this.projects = true,
    this.calendar = true,
    this.library = true,
    this.statistics = true,
    this.journal = false,
    this.finance = false,
  });

  factory AiPermissionScopes.fromJson(Map<String, Object?> json) {
    return AiPermissionScopes(
      enabled: json['enabled'] as bool? ?? false,
      canWrite: json['canWrite'] as bool? ?? true,
      tasks: json['tasks'] as bool? ?? true,
      plans: json['plans'] as bool? ?? true,
      habits: json['habits'] as bool? ?? true,
      goals: json['goals'] as bool? ?? true,
      projects: json['projects'] as bool? ?? true,
      calendar: json['calendar'] as bool? ?? true,
      library: json['library'] as bool? ?? true,
      statistics: json['statistics'] as bool? ?? true,
      journal: json['journal'] as bool? ?? false,
      finance: json['finance'] as bool? ?? false,
    );
  }

  final bool enabled;
  final bool canWrite;
  final bool tasks;
  final bool plans;
  final bool habits;
  final bool goals;
  final bool projects;
  final bool calendar;
  final bool library;
  final bool statistics;
  final bool journal;
  final bool finance;

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'canWrite': canWrite,
    'tasks': tasks,
    'plans': plans,
    'habits': habits,
    'goals': goals,
    'projects': projects,
    'calendar': calendar,
    'library': library,
    'statistics': statistics,
    'journal': journal,
    'finance': finance,
  };

  AiPermissionScopes copyWith({
    bool? enabled,
    bool? canWrite,
    bool? tasks,
    bool? plans,
    bool? habits,
    bool? goals,
    bool? projects,
    bool? calendar,
    bool? library,
    bool? statistics,
    bool? journal,
    bool? finance,
  }) {
    return AiPermissionScopes(
      enabled: enabled ?? this.enabled,
      canWrite: canWrite ?? this.canWrite,
      tasks: tasks ?? this.tasks,
      plans: plans ?? this.plans,
      habits: habits ?? this.habits,
      goals: goals ?? this.goals,
      projects: projects ?? this.projects,
      calendar: calendar ?? this.calendar,
      library: library ?? this.library,
      statistics: statistics ?? this.statistics,
      journal: journal ?? this.journal,
      finance: finance ?? this.finance,
    );
  }
}
