/// §5.3's card catalogue. `focus` isn't here — it's "always first, cannot
/// be hidden or moved," so it's rendered unconditionally by `HomeScreen`
/// rather than being a row a user can toggle. `reading`, `study`,
/// `activity` and `aiSuggestions` aren't built this pass — see
/// DECISIONS.md.
enum DashboardCardType {
  plansToday,
  habits,
  upcoming,
  goals,
  projects,
  recent,
  dailyStats,
  journalPrompt,
  spending,
  filmNext,
}

enum DashboardCardSize { small, medium, large }

/// §5.3/§5.4. One row on the Home dashboard, user-ordered and toggleable.
class AppDashboardCard {
  AppDashboardCard({
    required this.id,
    required this.userId,
    required this.type,
    required this.position,
    this.visible = true,
    this.size = DashboardCardSize.medium,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String userId;
  final DashboardCardType type;
  final int position;
  final bool visible;
  final DashboardCardSize size;
  final DateTime updatedAt;

  AppDashboardCard copyWith({int? position, bool? visible, DashboardCardSize? size}) {
    return AppDashboardCard(
      id: id,
      userId: userId,
      type: type,
      position: position ?? this.position,
      visible: visible ?? this.visible,
      size: size ?? this.size,
    );
  }
}

/// §5.3's own default set — "focus, plansToday, habits, upcoming, goals."
/// Every other catalog type still gets a row (so the customise screen has
/// something to toggle on), just not visible until the user turns it on.
const defaultVisibleDashboardCardTypes = {
  DashboardCardType.plansToday,
  DashboardCardType.habits,
  DashboardCardType.upcoming,
  DashboardCardType.goals,
};

const dashboardCardTypeOrder = DashboardCardType.values;
