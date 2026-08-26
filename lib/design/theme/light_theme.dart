import 'package:flutter/material.dart';
import 'package:life_os/design/theme/text_theme_builder.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/typography.dart';

ThemeData buildLightTheme({LifeAccentName accentName = LifeAccentName.signal}) {
  final colors = LifeColors.of(Brightness.light, accentName: accentName);
  final n = colors.neutrals;
  final textStyles = LifeTextStyles.standard();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: n.bg,
    canvasColor: n.bg,
    dividerColor: n.border,
    textTheme: buildLifeTextTheme(textStyles, n),
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.accent.base,
      primary: colors.accent.base,
      onPrimary: colors.accent.on,
      surface: n.surface,
      onSurface: n.ink,
      error: LifeSemanticColors.danger(Brightness.light).base,
      onError: LifeSemanticColors.danger(Brightness.light).on,
    ),
    extensions: [colors, textStyles],
  );
}
