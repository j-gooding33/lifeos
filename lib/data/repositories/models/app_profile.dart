/// The domain-level profile — feature code sees this, never Drift's
/// generated `Profile` row class (CLAUDE.md: "Domain models never leak
/// Drift or Supabase types into features/").
class AppProfile {
  const AppProfile({
    required this.id,
    this.displayName,
    this.avatarPath,
    this.timezone = 'UTC',
    this.weekStart = 1,
    this.currency = 'GBP',
    this.dateFormat = 'dmy',
    this.onboardedAt,
  });

  final String id;
  final String? displayName;
  final String? avatarPath;
  final String timezone;
  final int weekStart;
  final String currency;
  final String dateFormat;
  final DateTime? onboardedAt;

  AppProfile copyWith({
    String? displayName,
    String? avatarPath,
    String? timezone,
    int? weekStart,
    String? currency,
    String? dateFormat,
    DateTime? onboardedAt,
  }) {
    return AppProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      timezone: timezone ?? this.timezone,
      weekStart: weekStart ?? this.weekStart,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      onboardedAt: onboardedAt ?? this.onboardedAt,
    );
  }
}
