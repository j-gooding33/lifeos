import 'package:flutter/material.dart';

/// Clamps the platform text scale to 0.85–1.6 (§2.3) and exposes whether
/// the effective scale is past the 1.3 threshold at which cards switch
/// from horizontal to vertical layout. Wrap the app once in
/// [ScaledLayout.wrap]; read it anywhere below with `ScaledLayout.of(context)`.
class ScaledLayout extends InheritedWidget {
  const ScaledLayout({required this.isLarge, required super.child, super.key});

  static const minScale = 0.85;
  static const maxScale = 1.6;
  static const largeThreshold = 1.3;

  final bool isLarge;

  static ScaledLayout of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ScaledLayout>();
    assert(result != null, 'No ScaledLayout found in context');
    return result!;
  }

  static Widget wrap({required Widget child}) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final clamped = mediaQuery.textScaler.clamp(
          minScaleFactor: minScale,
          maxScaleFactor: maxScale,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clamped),
          child: ScaledLayout(
            isLarge: clamped.scale(1) > largeThreshold,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool updateShouldNotify(ScaledLayout oldWidget) => isLarge != oldWidget.isLarge;
}
