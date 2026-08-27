import 'package:flutter/material.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';

/// The golden-test harness's canonical "light" reference — the Ledger
/// scheme. Kept as a thin, zero-arg wrapper so `golden_harness.dart` (and
/// its `_light_*.png` golden filenames) didn't need to change when the theme-scheme system
/// replaced the single light/dark pair with four full [LifeThemeScheme]s.
ThemeData buildLightTheme() => buildThemeForScheme(LifeThemeScheme.ledger);
