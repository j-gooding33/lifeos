import 'package:flutter/material.dart';

/// The eight user-selectable accents (§2.2). `signal` is the default.
enum LifeAccentName { signal, pine, ember, bloom, iris, moss, tide, slate }

/// A colour with a base tone and a text colour guaranteed to meet 4.5:1
/// against that base (computed once at authoring time — see
/// `DECISIONS.md`, not recomputed at runtime).
@immutable
class LifeAccentColor {
  const LifeAccentColor({required this.base, required this.on});

  final Color base;
  final Color on;

  /// 12% alpha over whatever surface it's painted on top of.
  Color get soft => base.withValues(alpha: 0.12);
}

class LifeNeutrals {
  const LifeNeutrals({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceSunken,
    required this.border,
    required this.ink,
    required this.ink2,
    required this.ink3,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceSunken;
  final Color border;
  final Color ink;
  final Color ink2;
  final Color ink3;

  static const light = LifeNeutrals(
    bg: Color(0xFFFCFCFD),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF3F4F8),
    surfaceSunken: Color(0xFFEDEEF3),
    border: Color(0xFFE4E5EC),
    ink: Color(0xFF12131A),
    ink2: Color(0xFF62636F),
    ink3: Color(0xFF92939F),
  );

  static const dark = LifeNeutrals(
    bg: Color(0xFF0A0B0F),
    surface: Color(0xFF14151B),
    surfaceAlt: Color(0xFF1C1D25),
    surfaceSunken: Color(0xFF22232C),
    border: Color(0xFF282A34),
    ink: Color(0xFFF4F5F8),
    ink2: Color(0xFF9FA1AE),
    ink3: Color(0xFF6C6E7C),
  );
}

/// Dark-mode bases are the light-mode hue lifted ~10% in HSL lightness so
/// they hold contrast on `#0A0B0F` (§2.2). `on` is whichever of pure
/// black/white clears 4.5:1 against that theme's base — for these
/// mid-lightness accent colours that is black in dark mode even though the
/// dark theme's body-text ink is near-white; the accent fill itself, not
/// the page background, is what the text sits on. See DECISIONS.md.
const _lightAccents = <LifeAccentName, LifeAccentColor>{
  LifeAccentName.signal: LifeAccentColor(base: Color(0xFF4F5BD5), on: Color(0xFFFFFFFF)),
  LifeAccentName.pine: LifeAccentColor(base: Color(0xFF0F9E8E), on: Color(0xFF12131A)),
  LifeAccentName.ember: LifeAccentColor(base: Color(0xFFE0913A), on: Color(0xFF12131A)),
  LifeAccentName.bloom: LifeAccentColor(base: Color(0xFFDC5A8E), on: Color(0xFF12131A)),
  LifeAccentName.iris: LifeAccentColor(base: Color(0xFF7C5CE0), on: Color(0xFFFFFFFF)),
  LifeAccentName.moss: LifeAccentColor(base: Color(0xFF2FA05F), on: Color(0xFF12131A)),
  LifeAccentName.tide: LifeAccentColor(base: Color(0xFF3B7CF6), on: Color(0xFF12131A)),
  LifeAccentName.slate: LifeAccentColor(base: Color(0xFF6E7180), on: Color(0xFFFFFFFF)),
};

const _darkAccents = <LifeAccentName, LifeAccentColor>{
  LifeAccentName.signal: LifeAccentColor(base: Color(0xFF7881DF), on: Color(0xFF000000)),
  LifeAccentName.pine: LifeAccentColor(base: Color(0xFF13CDB8), on: Color(0xFF000000)),
  LifeAccentName.ember: LifeAccentColor(base: Color(0xFFE7AA66), on: Color(0xFF000000)),
  LifeAccentName.bloom: LifeAccentColor(base: Color(0xFFE584AB), on: Color(0xFF000000)),
  LifeAccentName.iris: LifeAccentColor(base: Color(0xFF9E87E8), on: Color(0xFF000000)),
  LifeAccentName.moss: LifeAccentColor(base: Color(0xFF3CC677), on: Color(0xFF000000)),
  LifeAccentName.tide: LifeAccentColor(base: Color(0xFF6C9DF8), on: Color(0xFF000000)),
  LifeAccentName.slate: LifeAccentColor(base: Color(0xFF888B99), on: Color(0xFF000000)),
};

class LifeAccents {
  const LifeAccents._();

  static LifeAccentColor of(LifeAccentName name, Brightness brightness) {
    final table = brightness == Brightness.dark ? _darkAccents : _lightAccents;
    return table[name]!;
  }
}

/// Fixed, not user-configurable — a domain colour always means the same
/// thing across Calendar, Stats and Your Year (§2.2).
class LifeDomainColors {
  const LifeDomainColors._();

  static const _light = <String, LifeAccentColor>{
    'tasks': LifeAccentColor(base: Color(0xFF3B7CF6), on: Color(0xFF12131A)),
    'plans': LifeAccentColor(base: Color(0xFF7C5CE0), on: Color(0xFFFFFFFF)),
    'habits': LifeAccentColor(base: Color(0xFF0F9E8E), on: Color(0xFF12131A)),
    'goals': LifeAccentColor(base: Color(0xFFE0913A), on: Color(0xFF12131A)),
    'events': LifeAccentColor(base: Color(0xFF6E7180), on: Color(0xFFFFFFFF)),
    'films': LifeAccentColor(base: Color(0xFFDC5A8E), on: Color(0xFF12131A)),
    'books': LifeAccentColor(base: Color(0xFF2FA05F), on: Color(0xFF12131A)),
    'study': LifeAccentColor(base: Color(0xFF4F5BD5), on: Color(0xFFFFFFFF)),
    'finance': LifeAccentColor(base: Color(0xFF8A6E52), on: Color(0xFFFFFFFF)),
  };

  static const _dark = <String, LifeAccentColor>{
    'tasks': LifeAccentColor(base: Color(0xFF6C9DF8), on: Color(0xFF000000)),
    'plans': LifeAccentColor(base: Color(0xFF9E87E8), on: Color(0xFF000000)),
    'habits': LifeAccentColor(base: Color(0xFF13CDB8), on: Color(0xFF000000)),
    'goals': LifeAccentColor(base: Color(0xFFE7AA66), on: Color(0xFF000000)),
    'events': LifeAccentColor(base: Color(0xFF888B99), on: Color(0xFF000000)),
    'films': LifeAccentColor(base: Color(0xFFE584AB), on: Color(0xFF000000)),
    'books': LifeAccentColor(base: Color(0xFF3CC677), on: Color(0xFF000000)),
    'study': LifeAccentColor(base: Color(0xFF7881DF), on: Color(0xFF000000)),
    'finance': LifeAccentColor(base: Color(0xFFA68869), on: Color(0xFF000000)),
  };

  static LifeAccentColor tasks(Brightness b) => (b == Brightness.dark ? _dark : _light)['tasks']!;
  static LifeAccentColor plans(Brightness b) => (b == Brightness.dark ? _dark : _light)['plans']!;
  static LifeAccentColor habits(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['habits']!;
  static LifeAccentColor goals(Brightness b) => (b == Brightness.dark ? _dark : _light)['goals']!;
  static LifeAccentColor events(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['events']!;
  static LifeAccentColor films(Brightness b) => (b == Brightness.dark ? _dark : _light)['films']!;
  static LifeAccentColor books(Brightness b) => (b == Brightness.dark ? _dark : _light)['books']!;
  static LifeAccentColor study(Brightness b) => (b == Brightness.dark ? _dark : _light)['study']!;
  static LifeAccentColor finance(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['finance']!;

  /// All domain (name, colour) pairs for the current brightness — for
  /// goldens and any legend/gallery that needs to enumerate them.
  static Map<String, LifeAccentColor> all(Brightness b) => b == Brightness.dark ? _dark : _light;
}

class LifeSemanticColors {
  const LifeSemanticColors._();

  static const _light = <String, LifeAccentColor>{
    'success': LifeAccentColor(base: Color(0xFF2FA05F), on: Color(0xFF12131A)),
    'warning': LifeAccentColor(base: Color(0xFFE0913A), on: Color(0xFF12131A)),
    'danger': LifeAccentColor(base: Color(0xFFDC4C4C), on: Color(0xFF12131A)),
    'info': LifeAccentColor(base: Color(0xFF3B7CF6), on: Color(0xFF12131A)),
  };

  static const _dark = <String, LifeAccentColor>{
    'success': LifeAccentColor(base: Color(0xFF3CC677), on: Color(0xFF000000)),
    'warning': LifeAccentColor(base: Color(0xFFE7AA66), on: Color(0xFF000000)),
    'danger': LifeAccentColor(base: Color(0xFFE47777), on: Color(0xFF000000)),
    'info': LifeAccentColor(base: Color(0xFF6C9DF8), on: Color(0xFF000000)),
  };

  static LifeAccentColor success(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['success']!;
  static LifeAccentColor warning(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['warning']!;
  static LifeAccentColor danger(Brightness b) =>
      (b == Brightness.dark ? _dark : _light)['danger']!;
  static LifeAccentColor info(Brightness b) => (b == Brightness.dark ? _dark : _light)['info']!;

  static Map<String, LifeAccentColor> all(Brightness b) => b == Brightness.dark ? _dark : _light;
}

/// The full colour token set for one theme, exposed via [ThemeExtension] so
/// feature code reads `Theme.of(context).extension<LifeColors>()!` instead
/// of touching hex values directly (CLAUDE.md rule 5).
@immutable
class LifeColors extends ThemeExtension<LifeColors> {
  const LifeColors({
    required this.brightness,
    required this.neutrals,
    required this.accentName,
    required this.accent,
  });

  factory LifeColors.of(Brightness brightness, {LifeAccentName accentName = LifeAccentName.signal}) {
    return LifeColors(
      brightness: brightness,
      neutrals: brightness == Brightness.dark ? LifeNeutrals.dark : LifeNeutrals.light,
      accentName: accentName,
      accent: LifeAccents.of(accentName, brightness),
    );
  }

  final Brightness brightness;
  final LifeNeutrals neutrals;
  final LifeAccentName accentName;
  final LifeAccentColor accent;

  LifeAccentColor domain(String name) => LifeDomainColors.all(brightness)[name]!;
  LifeAccentColor semantic(String name) => LifeSemanticColors.all(brightness)[name]!;

  @override
  LifeColors copyWith({LifeAccentName? accentName}) {
    return LifeColors.of(brightness, accentName: accentName ?? this.accentName);
  }

  @override
  LifeColors lerp(ThemeExtension<LifeColors>? other, double t) {
    // Neutral/accent tables are discrete per theme, not interpolated.
    if (other is! LifeColors || t >= 0.5) return other as LifeColors? ?? this;
    return this;
  }
}
