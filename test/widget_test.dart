import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/app.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/database.dart';

/// `path_provider` (which the real `AppDatabase()` needs) has no platform
/// channel in `flutter_test`, so every widget test overrides it with an
/// in-memory database — see the same note in `route_resolution_test.dart`.
Widget _appUnderTest() {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory()))],
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

  testWidgets('shows all five tabs', (tester) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pumpAndSettle();

    for (final label in ['Plans', 'Tasks', 'Library', 'Stats']) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }
    // "Home" is both a tab label and, on the Home screen itself, only ever
    // the AppBar's greeting text now — not the literal word "Home" — so it
    // no longer needs the double-match note the other labels don't have.
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
