import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/app.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/features/onboarding/application/onboarding_providers.dart';

/// `path_provider` (which the real `AppDatabase()` needs) has no platform
/// channel in `flutter_test`, so every widget test overrides it with an
/// in-memory database — see the same note in `route_resolution_test.dart`.
/// [onboarded] defaults to true so tests about tab navigation don't also
/// have to deal with the onboarding gate; the gate itself gets its own
/// test below with `onboarded: false`.
Widget _appUnderTest({bool onboarded = true}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory())),
      if (onboarded) hasOnboardedProvider.overrideWith((ref) => Stream.value(true)),
    ],
    child: const LifeOsApp(),
  );
}

void main() {
  setUp(() => AppConfig.initialize(Flavor.dev));

  testWidgets('boots to the Home tab, no fake UI', (tester) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsAtLeastNWidgets(1));
    // Home is a real database-backed screen now (M5) — flush the Drift
    // stream-cleanup timer it schedules on dispose before the test
    // framework's teardown runs its "no pending timers" check. Same fix as
    // `route_resolution_test.dart`.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('shows the four built tabs, Stats hidden until built', (tester) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pumpAndSettle();

    for (final label in ['Plans', 'Tasks', 'Library']) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }
    // Stats is deliberately off the bar (see shell_scaffold.dart) until it
    // has a real screen behind it — its route stays reachable by deep link.
    expect(find.text('Stats'), findsNothing);
    // "Home" is both a tab label and, on the Home screen itself, only ever
    // the AppBar's greeting text now — not the literal word "Home" — so it
    // no longer needs the double-match note the other labels don't have.
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });

  testWidgets('a first-run user (hasOnboarded false) sees onboarding, not the tab bar', (tester) async {
    await tester.pumpWidget(_appUnderTest(onboarded: false));
    await tester.pumpAndSettle();

    expect(find.text('What do you want to start doing?'), findsOneWidget);
    expect(find.text('Plans'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
