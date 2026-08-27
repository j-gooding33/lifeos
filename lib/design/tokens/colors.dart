import 'package:flutter/material.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';

/// The eight per-plan tag colours (§7.2, `plan_colour.dart`) — independent
/// of [LifeThemeScheme]. `signal` is the default.
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

  /// Theme schemes: the four [LifeThemeScheme] neutral palettes. `light`/`dark` above
  /// are the original M2 pair, superseded as the shipped look but left in
  /// place — `contrast_test.dart` still exercises them as token data.
  static const ledger = LifeNeutrals(
    bg: Color(0xFFF4F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDF1F6),
    surfaceSunken: Color(0xFFE4E9F0),
    border: Color(0xFFDBE2EC),
    ink: Color(0xFF10151F),
    ink2: Color(0xFF56606F),
    ink3: Color(0xFF8B94A3),
  );

  static const afterHours = LifeNeutrals(
    bg: Color(0xFF0D1117),
    surface: Color(0xFF161B24),
    surfaceAlt: Color(0xFF1D232E),
    surfaceSunken: Color(0xFF232A36),
    border: Color(0xFF262D3A),
    ink: Color(0xFFF3F5F8),
    ink2: Color(0xFFA7AFC0),
    ink3: Color(0xFF626A7C),
  );

  static const fieldnotes = LifeNeutrals(
    bg: Color(0xFFECE7DB),
    surface: Color(0xFFFAF8F2),
    surfaceAlt: Color(0xFFE2DECF),
    surfaceSunken: Color(0xFFDAD4C2),
    border: Color(0xFFDCD5C1),
    ink: Color(0xFF2B2A22),
    ink2: Color(0xFF5A5442),
    ink3: Color(0xFF948C72),
  );

  static const signal = LifeNeutrals(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F2F2),
    surfaceSunken: Color(0xFFE8E8E8),
    border: Color(0xFF141414),
    ink: Color(0xFF0A0A0A),
    ink2: Color(0xFF54555A),
    ink3: Color(0xFF9A9A9E),
  );

  static LifeNeutrals forScheme(LifeThemeScheme scheme) => switch (scheme) {
    LifeThemeScheme.ledger => ledger,
    LifeThemeScheme.afterHours => afterHours,
    LifeThemeScheme.fieldnotes => fieldnotes,
    LifeThemeScheme.signal => signal,
  };
}

/// One signature accent per [LifeThemeScheme] — the primary-button/FAB/
/// selected-nav colour for that theme (distinct from the eight
/// [LifeAccentName] plan-tag colours above).
const _schemeAccents = <LifeThemeScheme, LifeAccentColor>{
  LifeThemeScheme.ledger: LifeAccentColor(base: Color(0xFF2952E3), on: Color(0xFFFFFFFF)),
  LifeThemeScheme.afterHours: LifeAccentColor(base: Color(0xFFFF8A5B), on: Color(0xFF1A0D05)),
  LifeThemeScheme.fieldnotes: LifeAccentColor(base: Color(0xFF546B46), on: Color(0xFFF6F4EA)),
  LifeThemeScheme.signal: LifeAccentColor(base: Color(0xFF0046FF), on: Color(0xFFFFFFFF)),
};

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

/// The full colour token set for one [LifeThemeScheme], exposed via
/// [ThemeExtension] so feature code reads
/// `Theme.of(context).extension<LifeColors>()!` instead of touching hex
/// values or a scheme directly (CLAUDE.md rule 5).
@immutable
class LifeColors extends ThemeExtension<LifeColors> {
  const LifeColors({required this.scheme, required this.neutrals, required this.accent});

  factory LifeColors.forScheme(LifeThemeScheme scheme) {
    return LifeColors(scheme: scheme, neutrals: LifeNeutrals.forScheme(scheme), accent: _schemeAccents[scheme]!);
  }

  final LifeThemeScheme scheme;
  final LifeNeutrals neutrals;
  final LifeAccentColor accent;

  Brightness get brightness => scheme.brightness;

  LifeAccentColor domain(String name) => LifeDomainColors.all(brightness)[name]!;
  LifeAccentColor semantic(String name) => LifeSemanticColors.all(brightness)[name]!;

  @override
  LifeColors copyWith({LifeThemeScheme? scheme}) {
    return LifeColors.forScheme(scheme ?? this.scheme);
  }

  @override
  LifeColors lerp(ThemeExtension<LifeColors>? other, double t) {
    // Neutral/accent tables are discrete per scheme, not interpolated.
    if (other is! LifeColors || t >= 0.5) return other as LifeColors? ?? this;
    return this;
  }
}
