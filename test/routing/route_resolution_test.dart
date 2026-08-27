import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/design/theme/light_theme.dart';
import 'package:life_os/routing/router.dart';

/// Every path in the §3.2 route table, with sample values for path
/// parameters. M3's DoD is "every route in §3.2 resolves" — this is that
/// check, run without a real device (no `IntegrationTestWidgetsFlutterBinding`
/// available on this Windows dev machine — see DECISIONS.md).
const _routeTablePaths = [
  '/onboarding',
  '/auth/sign-in',
  '/auth/sign-up',
  '/auth/reset',
  '/home',
  '/home/day/2026-09-01',
  '/home/briefing/morning',
  '/home/customise',
  '/plans',
  '/plans/new',
  '/plans/abc123',
  '/plans/abc123/edit',
  '/plans/abc123/calendar',
  '/plans/abc123/occurrence/occ1',
  '/habits',
  '/habits/abc123',
  '/calendar',
  '/calendar/event/abc123',
  '/tasks',
  '/tasks/new',
  '/tasks/abc123',
  '/projects',
  '/projects/abc123',
  '/projects/abc123/new-task',
  '/goals',
  '/goals/new',
  '/goals/abc123',
  '/library',
  '/library/films',
  '/library/films/search',
  '/library/films/abc123',
  '/library/tv',
  '/library/tv/abc123',
  '/library/books',
  '/library/books/search',
  '/library/books/abc123',
  '/library/notes',
  '/library/notes/abc123',
  '/library/collections/abc123',
  '/library/links',
  '/stats',
  '/stats/year',
  '/stats/tasks',
  '/journal',
  '/journal/2026-09-01',
  '/finance',
  '/finance/expense/abc123',
  '/finance/budgets',
  '/search',
  '/ai',
  '/ai/conversation/abc123',
  '/settings',
  '/settings/account',
  '/settings/profile',
  '/settings/appearance',
  '/settings/home',
  '/settings/notifications',
  '/settings/ai',
  '/settings/privacy',
  '/settings/data',
  '/settings/calendar',
  '/settings/integrations',
  '/settings/subscription',
  '/settings/about',
  '/dev/components',
];

/// Routes now include real, database-backed screens (Tasks, from M5), so
/// every test needs a `ProviderScope` with an in-memory database override
/// — `path_provider` (which the real `AppDatabase()` needs to find the
/// documents directory) has no platform channel in `flutter_test`.
Widget _pumpableApp(GoRouter router) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
    ],
    child: MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
  );
}

void main() {
  setUp(() => AppConfig.initialize(Flavor.dev));

  testWidgets('every route in the §3.2 table resolves without error', (
    tester,
  ) async {
    final router = buildRouter();
    await tester.pumpWidget(_pumpableApp(router));
    await tester.pumpAndSettle();

    for (final path in _routeTablePaths) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$path threw while resolving',
      );
      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: '$path rendered no Scaffold',
      );
    }
  });

  group('§3.4 deep-link aliases redirect to the right in-app screen', () {
    testWidgets('/task/:id -> task detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(_pumpableApp(router));
      router.go('/task/abc123');
      await tester.pumpAndSettle();
      // A real screen now (M5) — abc123 doesn't exist in the fresh test
      // database, so it resolves to the "no longer exists" state rather
      // than a placeholder, which is itself proof the redirect landed on
      // the real task-detail route rather than somewhere else.
      expect(find.text('This task no longer exists.'), findsOneWidget);
      // Drift schedules a zero-duration cleanup timer when a stream query
      // is torn down. That teardown only happens once the widget tree is
      // unmounted, which the test framework normally does *after* the
      // test body returns — too late to flush with a pump from inside the
      // body. Force the unmount here instead, then flush the timer it
      // creates, so nothing is left pending when the framework's own
      // teardown runs its "no pending timers" check.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('/plan/:id -> plan detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(_pumpableApp(router));
      router.go('/plan/abc123');
      await tester.pumpAndSettle();
      // A real screen now (M6) — abc123 doesn't exist in the fresh test
      // database, so it resolves to the "no longer exists" state rather
      // than a placeholder, which is itself proof the redirect landed on
      // the real plan-detail route rather than somewhere else.
      expect(find.text('This plan no longer exists.'), findsOneWidget);
      // Home (the initial location) is a real database-backed screen now
      // (M5) and stays mounted inside the shell's IndexedStack even after
      // navigating away, so it needs the same forced-unmount flush as the
      // task-detail case above.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('/day/:date -> day detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(_pumpableApp(router));
      router.go('/day/2026-09-01');
      await tester.pumpAndSettle();
      expect(find.text('Day detail'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('/quickadd -> quick add type picker', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(_pumpableApp(router));
      router.go('/quickadd');
      await tester.pumpAndSettle();
      expect(find.text('What are you adding?'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });

    testWidgets('/occurrence/:id -> occurrence detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(_pumpableApp(router));
      router.go('/occurrence/occ1');
      await tester.pumpAndSettle();
      // A real screen now (M7) — occ1 doesn't exist in the fresh test
      // database, so it resolves to the "no longer exists" state rather
      // than a placeholder, which is itself proof the route landed on the
      // real occurrence screen rather than somewhere else.
      expect(find.text('This occurrence no longer exists.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });
  });
}
