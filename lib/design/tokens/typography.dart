import 'package:flutter/material.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';

/// The original M2 trio — superseded by [LifeSchemeFonts] as the shipped
/// look but left in place; nothing outside this file references it.
class LifeFontFamily {
  const LifeFontFamily._();

  static const display = 'InstrumentSans';
  static const body = 'Inter';
  static const mono = 'IBMPlexMono';
}

/// Theme schemes: the type trio for each [LifeThemeScheme] — a display face, a body
/// face, and a mono face, all SIL OFL and bundled locally (§2.3). Bebas
/// Neue only ships one weight, hence [displayWeight] instead of a fixed
/// `w600` — every other display style is available at the weight the
/// scheme calls for.
class LifeSchemeFonts {
  const LifeSchemeFonts._();

  static const _display = <LifeThemeScheme, String>{
    LifeThemeScheme.ledger: 'Archivo',
    LifeThemeScheme.afterHours: 'Sora',
    LifeThemeScheme.fieldnotes: 'Fraunces',
    LifeThemeScheme.signal: 'BebasNeue',
  };

  static const _body = <LifeThemeScheme, String>{
    LifeThemeScheme.ledger: 'IBMPlexSans',
    LifeThemeScheme.afterHours: 'Inter',
    LifeThemeScheme.fieldnotes: 'PublicSans',
    LifeThemeScheme.signal: 'WorkSans',
  };

  static const _mono = <LifeThemeScheme, String>{
    LifeThemeScheme.ledger: 'IBMPlexMono',
    LifeThemeScheme.afterHours: 'JetBrainsMono',
    LifeThemeScheme.fieldnotes: 'IBMPlexMono',
    LifeThemeScheme.signal: 'IBMPlexMono',
  };

  static const _displayWeight = <LifeThemeScheme, FontWeight>{
    LifeThemeScheme.ledger: FontWeight.w700,
    LifeThemeScheme.afterHours: FontWeight.w600,
    LifeThemeScheme.fieldnotes: FontWeight.w600,
    LifeThemeScheme.signal: FontWeight.w400,
  };

  static String display(LifeThemeScheme s) => _display[s]!;
  static String body(LifeThemeScheme s) => _body[s]!;
  static String mono(LifeThemeScheme s) => _mono[s]!;
  static FontWeight displayWeight(LifeThemeScheme s) => _displayWeight[s]!;
}

/// Text style scale (§2.3). Family assignment resolves one ambiguity in the
/// spec: the "big stat numbers" phrase under the Display family bullet vs.
/// the later "any number that represents a measurement is set in mono"
/// rule. `statNumber` follows the latter, more specific rule (it's a
/// literal description of the §7.5 stats-strip mockup), so it's set in
/// `IBMPlexMono`, not `InstrumentSans`. See DECISIONS.md.
///
/// None of these set a colour — colour is a separate, composable token
/// (`LifeColors`); apply it with `.copyWith(color: ...)` at the call site.
@immutable
class LifeTextStyles extends ThemeExtension<LifeTextStyles> {
  const LifeTextStyles({
    required this.display,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.body,
    required this.bodyStrong,
    required this.callout,
    required this.subhead,
    required this.caption,
    required this.micro,
    required this.mono,
    required this.statNumber,
  });

  factory LifeTextStyles.forScheme(LifeThemeScheme scheme) {
    final display = LifeSchemeFonts.display(scheme);
    final displayWeight = LifeSchemeFonts.displayWeight(scheme);
    final body = LifeSchemeFonts.body(scheme);
    final mono = LifeSchemeFonts.mono(scheme);

    return LifeTextStyles(
      display: TextStyle(
        fontFamily: display,
        fontSize: 34,
        height: 40 / 34,
        fontWeight: displayWeight,
        letterSpacing: -0.68,
      ),
      title1: TextStyle(fontFamily: display, fontSize: 28, height: 34 / 28, fontWeight: displayWeight),
      title2: TextStyle(fontFamily: display, fontSize: 22, height: 28 / 22, fontWeight: displayWeight),
      title3: TextStyle(fontFamily: body, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600),
      body: TextStyle(fontFamily: body, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
      bodyStrong: TextStyle(fontFamily: body, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
      callout: TextStyle(fontFamily: body, fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400),
      subhead: TextStyle(fontFamily: body, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
      caption: TextStyle(fontFamily: body, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500),
      // Uppercase is a presentation step for the caller (e.g. `.toUpperCase()`
      // on the string) — TextStyle has no case transform of its own.
      micro: TextStyle(
        fontFamily: body,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.44,
      ),
      mono: TextStyle(
        fontFamily: mono,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      statNumber: TextStyle(
        fontFamily: mono,
        fontSize: 40,
        height: 44 / 40,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  final TextStyle display;
  final TextStyle title1;
  final TextStyle title2;
  final TextStyle title3;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle callout;
  final TextStyle subhead;
  final TextStyle caption;
  final TextStyle micro;
  final TextStyle mono;
  final TextStyle statNumber;

  @override
  LifeTextStyles copyWith() => this;

  @override
  LifeTextStyles lerp(ThemeExtension<LifeTextStyles>? other, double t) {
    if (other is! LifeTextStyles) return this;
    return LifeTextStyles(
      display: TextStyle.lerp(display, other.display, t)!,
      title1: TextStyle.lerp(title1, other.title1, t)!,
      title2: TextStyle.lerp(title2, other.title2, t)!,
      title3: TextStyle.lerp(title3, other.title3, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      callout: TextStyle.lerp(callout, other.callout, t)!,
      subhead: TextStyle.lerp(subhead, other.subhead, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      micro: TextStyle.lerp(micro, other.micro, t)!,
      mono: TextStyle.lerp(mono, other.mono, t)!,
      statNumber: TextStyle.lerp(statNumber, other.statNumber, t)!,
    );
  }
}
