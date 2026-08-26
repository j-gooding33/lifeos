/// Spacing scale (§2.4). Always use these instead of ad-hoc `EdgeInsets`
/// numbers in feature code (CLAUDE.md rule 5).
class LifeSpace {
  const LifeSpace._();

  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s56 = 56.0;

  /// Screen horizontal padding.
  static const screenHorizontal = s20;

  /// Card internal padding.
  static const cardPadding = s16;

  /// Gap between cards in a list.
  static const cardGap = s12;
}

class LifeRadius {
  const LifeRadius._();

  static const chip = 8.0;
  static const control = 12.0;
  static const card = 16.0;
  static const cardLarge = 20.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}
