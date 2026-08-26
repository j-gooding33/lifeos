import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/config/flavor.dart';
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

void main() {
  setUp(() => AppConfig.initialize(Flavor.dev));

  testWidgets('every route in the §3.2 table resolves without error', (tester) async {
    final router = buildRouter();
    await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
    await tester.pumpAndSettle();

    for (final path in _routeTablePaths) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path threw while resolving');
      expect(find.byType(Scaffold), findsWidgets, reason: '$path rendered no Scaffold');
    }
  });

  group('§3.4 deep-link aliases redirect to the right in-app screen', () {
    testWidgets('/task/:id -> task detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
      router.go('/task/abc123');
      await tester.pumpAndSettle();
      expect(find.text('Task detail'), findsOneWidget);
    });

    testWidgets('/plan/:id -> plan detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
      router.go('/plan/abc123');
      await tester.pumpAndSettle();
      expect(find.text('Plan detail'), findsOneWidget);
    });

    testWidgets('/day/:date -> day detail', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
      router.go('/day/2026-09-01');
      await tester.pumpAndSettle();
      expect(find.text('Day detail'), findsOneWidget);
    });

    testWidgets('/quickadd -> honest placeholder (Quick Add ships in M5)', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
      router.go('/quickadd');
      await tester.pumpAndSettle();
      expect(find.text('Quick Add'), findsOneWidget);
    });

    testWidgets('/occurrence/:id -> honest placeholder (needs M7 repository)', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(theme: buildLightTheme(), routerConfig: router));
      router.go('/occurrence/occ1');
      await tester.pumpAndSettle();
      expect(find.text('Occurrence'), findsOneWidget);
    });
  });
}
