import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test in this directory tree. Golden tests need the
/// real bundled fonts loaded, or every string renders in the fallback test
/// font regardless of the `fontFamily` we set (a well-known Flutter test
/// gotcha — `flutter_test` doesn't load app assets by default).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('InstrumentSans', ['assets/fonts/InstrumentSans-Variable.ttf']);
  await _loadFont('Inter', ['assets/fonts/Inter-Variable.ttf']);
  await _loadFont('IBMPlexMono', [
    'assets/fonts/IBMPlexMono-Regular.ttf',
    'assets/fonts/IBMPlexMono-Medium.ttf',
    'assets/fonts/IBMPlexMono-SemiBold.ttf',
  ]);
  // The other three theme schemes' faces (see DECISIONS.md) — same gotcha.
  await _loadFont('Archivo', ['assets/fonts/Archivo-Variable.ttf']);
  await _loadFont('IBMPlexSans', ['assets/fonts/IBMPlexSans-Variable.ttf']);
  await _loadFont('Sora', ['assets/fonts/Sora-Variable.ttf']);
  await _loadFont('JetBrainsMono', ['assets/fonts/JetBrainsMono-Variable.ttf']);
  await _loadFont('Fraunces', ['assets/fonts/Fraunces-Variable.ttf']);
  await _loadFont('PublicSans', ['assets/fonts/PublicSans-Variable.ttf']);
  await _loadFont('BebasNeue', ['assets/fonts/BebasNeue-Regular.ttf']);
  await _loadFont('WorkSans', ['assets/fonts/WorkSans-Variable.ttf']);
  // Icons are glyphs in a font too (`uses-material-design: true` bundles
  // this at the same asset key in the real app) — without it, every
  // `Icon()` renders as a `.notdef` box in tests.
  await _loadFont('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
  return testMain();
}

Future<void> _loadFont(String family, List<String> assetPaths) async {
  final loader = FontLoader(family);
  for (final path in assetPaths) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}
