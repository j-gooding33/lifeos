import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/core/notifications/notification_providers.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/design/theme/scheme_theme.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/features/onboarding/application/onboarding_providers.dart';
import 'package:life_os/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:life_os/features/settings/application/settings_providers.dart';
import 'package:life_os/routing/router.dart';
import 'package:life_os/routing/routes.dart';

class LifeOsApp extends ConsumerStatefulWidget {
  const LifeOsApp({super.key});

  @override
  ConsumerState<LifeOsApp> createState() => _LifeOsAppState();
}

class _LifeOsAppState extends ConsumerState<LifeOsApp> with WidgetsBindingObserver {
  // Built once, lazily, on first access — switching the theme scheme
  // rebuilds this widget, and a fresh `GoRouter` on every rebuild would
  // reset navigation back to `initialLocation` on every theme change.
  // Lazy also means a first-run user who hasn't onboarded yet never
  // constructs it at all until hasOnboarded flips true below.
  late final GoRouter _router = buildRouter();
  var _notificationsKickedOff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // §22.3: "reschedules on: app resume, any write to a source, timezone
  // change, and the daily maintenance job." App resume is the one of
  // those four with an obvious, general hook available here; the others
  // would need every write path across every feature to know about
  // notifications, which is a lot of surface for what's still a v1 of
  // this feature — see DECISIONS.md.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rescheduleNotifications();
  }

  // `setNotificationTapHandler` is cheap and safe regardless of whether
  // notifications are on — it only records where a tap should route to.
  // `rescheduleAll` is what actually checks the master switch and (only
  // when it's on) touches the plugin, which is what triggers the OS
  // permission prompt — see NotificationScheduler for why that ordering
  // matters (found live-testing: the prompt was firing on first app open,
  // before the user had ever touched Settings → Notifications).
  Future<void> _rescheduleNotifications() async {
    final scheduler = ref.read(notificationSchedulerProvider)..notificationTapHandler = _handleNotificationTap;
    final userId = await ref.read(currentUserIdProvider.future);
    await scheduler.rescheduleAll(userId);
  }

  void _handleNotificationTap(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final (type, id) = (parts[0], parts[1]);
    final route = switch (type) {
      'task' => Routes.taskDetail.replaceFirst(':id', id),
      'plan' => Routes.planDetail.replaceFirst(':id', id),
      'event' => Routes.calendarEvent.replaceFirst(':id', id),
      'project' => Routes.projectDetail.replaceFirst(':id', id),
      'goal' => Routes.goalDetail.replaceFirst(':id', id),
      _ => null,
    };
    if (route != null) _router.push(route);
  }

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

    // First real-app frame after onboarding is also the first "resume"
    // this session will ever see, so the initial schedule needs its own
    // kick here rather than waiting for a lifecycle transition that may
    // not come for a while on a fresh install. Guarded to fire once per
    // app launch, not on every rebuild this widget happens to go through
    // (a theme change, for instance).
    if (!_notificationsKickedOff) {
      _notificationsKickedOff = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _rescheduleNotifications());
    }

    return MaterialApp.router(
      title: AppConfig.instance.appName,
      theme: theme,
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      routerConfig: _router,
    );
  }
}
