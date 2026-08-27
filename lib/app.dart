import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/features/settings/application/settings_providers.dart';
import 'package:life_os/routing/router.dart';

class LifeOsApp extends ConsumerWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No separate light/dark toggle (theme schemes): the chosen scheme carries its own
    // brightness. Defaults to After Hours before the persisted preference
    // resolves — usually imperceptible, since it's a local SQLite read.
    final scheme = ref.watch(currentThemeSchemeProvider).value ?? LifeThemeScheme.afterHours;
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      theme: buildThemeForScheme(scheme),
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      routerConfig: buildRouter(),
    );
  }
}
