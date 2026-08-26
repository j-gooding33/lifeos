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
