import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/features/onboarding/application/onboarding_providers.dart';
import 'package:life_os/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:life_os/features/settings/application/settings_providers.dart';
import 'package:life_os/routing/router.dart';

class LifeOsApp extends ConsumerStatefulWidget {
  const LifeOsApp({super.key});

  @override
  ConsumerState<LifeOsApp> createState() => _LifeOsAppState();
}

class _LifeOsAppState extends ConsumerState<LifeOsApp> {
  // Built once, lazily, on first access — switching the theme scheme
  // rebuilds this widget, and a fresh `GoRouter` on every rebuild would
  // reset navigation back to `initialLocation` on every theme change.
  // Lazy also means a first-run user who hasn't onboarded yet never
  // constructs it at all until hasOnboarded flips true below.
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    // No separate light/dark toggle: the chosen scheme carries its own
    // brightness. Defaults to After Hours before the persisted preference
    // resolves — usually imperceptible, since it's a local SQLite read.
    final scheme = ref.watch(currentThemeSchemeProvider).value ?? LifeThemeScheme.afterHours;
    final theme = buildThemeForScheme(scheme);
    final hasOnboarded = ref.watch(hasOnboardedProvider);

    // First run (item 8): show the onboarding flow full-screen, with no
    // router at all, instead of a redirect gate on every navigation —
    // completeOnboarding() flips hasOnboardedProvider, this rebuilds, and
    // that's when the real router (and its Home tab) gets built for the
    // first time. While the flag is still loading (a local SQLite read,
    // effectively instant) or fails to load, fail open to the real app
    // rather than ever trap a returning user on a blank screen.
    if (hasOnboarded.value == false) {
      return MaterialApp(
        title: AppConfig.instance.appName,
        theme: theme,
        builder: (context, child) => ScaledLayout.wrap(child: child!),
        home: const OnboardingScreen(),
      );
    }

    return MaterialApp.router(
      title: AppConfig.instance.appName,
      theme: theme,
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      routerConfig: _router,
    );
  }
}
