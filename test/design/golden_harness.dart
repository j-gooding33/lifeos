import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/design/theme/dark_theme.dart';
import 'package:life_os/design/theme/light_theme.dart';

const goldenBrightnesses = [Brightness.light, Brightness.dark];
const goldenTextScales = [1.0, 1.5];

/// Pumps [child] inside a themed, text-scaled harness and settles past
/// every motion-token duration (§2.5's longest is 420ms) in one jump —
/// safe even for `LLoadingShimmer`'s indefinitely-repeating animation,
/// which `pumpAndSettle` would hang on.
Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
  required double textScale,
}) async {
  final theme = brightness == Brightness.dark ? buildDarkTheme() : buildLightTheme();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: RepaintBoundary(key: const Key('golden-target'), child: child),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

/// Runs [builder] across both themes and both text scales, golden-matching
/// each combination (§2 M2 DoD: "golden tests at scale 1.0 and 1.5 in both
/// themes").
void goldenMatrix(String name, Widget Function() builder) {
  for (final brightness in goldenBrightnesses) {
    for (final scale in goldenTextScales) {
      testWidgets('$name ($brightness @ ${scale}x)', (tester) async {
        await pumpGolden(tester, builder(), brightness: brightness, textScale: scale);
        await expectLater(
          find.byKey(const Key('golden-target')),
          matchesGoldenFile('goldens/${name}_${brightness.name}_$scale.png'),
        );
      });
    }
  }
}

/// Same matrix, for components whose interesting content is a triggered
/// overlay (sheet/menu/toast/dialog) rather than the trigger widget
/// itself: taps [triggerLabel] after the initial pump, then golden-matches
/// the whole screen since overlay content sits outside the trigger's
/// `RepaintBoundary`.
void goldenOverlayMatrix(
  String name, {
  required String triggerLabel,
  required Widget Function() builder,
}) {
  for (final brightness in goldenBrightnesses) {
    for (final scale in goldenTextScales) {
      testWidgets('$name ($brightness @ ${scale}x)', (tester) async {
        await pumpGolden(tester, builder(), brightness: brightness, textScale: scale);
        await tester.tap(find.text(triggerLabel));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${name}_${brightness.name}_$scale.png'),
        );
      });
    }
  }
}
