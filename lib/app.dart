import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/features/settings/application/settings_providers.dart';
import 'package:life_os/routing/router.dart';

class LifeOsApp extends ConsumerStatefulWidget {
  const LifeOsApp({super.key});

  @override
  ConsumerState<LifeOsApp> createState() => _LifeOsAppState();
}

class _LifeOsAppState extends ConsumerState<LifeOsApp> {
  // Built once and reused — switching the theme scheme rebuilds this
  // widget, and a fresh `GoRouter` on every rebuild would reset navigation
  // back to `initialLocation` on every theme change.
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    // No separate light/dark toggle: the chosen scheme carries its own
    // brightness. Defaults to After Hours before the persisted preference
    // resolves — usually imperceptible, since it's a local SQLite read.
    final scheme = ref.watch(currentThemeSchemeProvider).value ?? LifeThemeScheme.afterHours;
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      theme: buildThemeForScheme(scheme),
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      routerConfig: _router,
    );
  }
}
