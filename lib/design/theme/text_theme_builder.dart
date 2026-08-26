import 'package:flutter/material.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/typography.dart';

/// Maps our type scale onto Flutter's [TextTheme] roles, so that Material
/// widgets we don't style ourselves (AppBar, SnackBar, Dialog titles,
/// default `Text()`) still render in the app's typefaces and ink colour
/// instead of silently falling back to Roboto (§2.3, CLAUDE.md rule 5).
TextTheme buildLifeTextTheme(LifeTextStyles t, LifeNeutrals n) {
  return TextTheme(
    displayLarge: t.display.copyWith(color: n.ink),
    displayMedium: t.title1.copyWith(color: n.ink),
    displaySmall: t.title2.copyWith(color: n.ink),
    titleLarge: t.title2.copyWith(color: n.ink),
    titleMedium: t.title3.copyWith(color: n.ink),
    titleSmall: t.subhead.copyWith(color: n.ink),
    bodyLarge: t.body.copyWith(color: n.ink),
    bodyMedium: t.body.copyWith(color: n.ink),
    bodySmall: t.callout.copyWith(color: n.ink2),
    labelLarge: t.bodyStrong.copyWith(color: n.ink),
    labelMedium: t.subhead.copyWith(color: n.ink),
    labelSmall: t.micro.copyWith(color: n.ink2),
  );
}
