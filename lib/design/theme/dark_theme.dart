import 'package:flutter/material.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';

/// The golden-test harness's canonical "dark" reference — the After Hours
/// scheme, which is also the app's shipped default. See `light_theme.dart`.
ThemeData buildDarkTheme() => buildThemeForScheme(LifeThemeScheme.afterHours);
