import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/app.dart';
import 'package:life_os/core/config/flavor.dart';

void main() {
  setUp(() => AppConfig.initialize(Flavor.dev));

  testWidgets('boots to the Home tab with an honest placeholder, no fake UI', (
    tester,
  ) async {
    await tester.pumpWidget(const LifeOsApp());
    await tester.pumpAndSettle();

    expect(find.text('Not built yet'), findsOneWidget);
    expect(find.textContaining("hasn't shipped"), findsOneWidget);
  });

  testWidgets('shows all five tabs', (tester) async {
    await tester.pumpWidget(const LifeOsApp());
    await tester.pumpAndSettle();

    // "Home" also happens to be the current screen's AppBar title, so more
    // than one match is expected — this just confirms each tab label is on
    // screen at all, not that it's unique.
    for (final label in ['Home', 'Plans', 'Tasks', 'Library', 'Stats']) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }
  });
}
