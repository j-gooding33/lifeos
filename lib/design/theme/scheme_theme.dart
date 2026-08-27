import 'package:flutter/material.dart';
import 'package:life_os/design/theme/text_theme_builder.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/design/tokens/typography.dart';

/// Theme schemes: builds a complete [ThemeData] for one [LifeThemeScheme] — palette,
/// accent and type all sourced from that one scheme, never mixed across
/// schemes. The app itself only ever has one active theme at a time (no
/// separate light/dark toggle — see `theme_scheme.dart`).
ThemeData buildThemeForScheme(LifeThemeScheme scheme) {
  final colors = LifeColors.forScheme(scheme);
  final n = colors.neutrals;
  final textStyles = LifeTextStyles.forScheme(scheme);
  final brightness = scheme.brightness;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: n.bg,
    canvasColor: n.bg,
    dividerColor: n.border,
    textTheme: buildLifeTextTheme(textStyles, n),
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.accent.base,
      brightness: brightness,
      primary: colors.accent.base,
      onPrimary: colors.accent.on,
      surface: n.surface,
      onSurface: n.ink,
      error: LifeSemanticColors.danger(brightness).base,
      onError: LifeSemanticColors.danger(brightness).on,
    ),
    extensions: [colors, textStyles],
  );
}
