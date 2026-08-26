import 'package:flutter/material.dart';

/// Motion tokens (§2.5). `stagger` is per-item delay for list-entry
/// animations, capped at [staggerMaxItems] items; never animate a list
/// entry beyond that, and never animate a list longer than 12 items.
class LifeMotion {
  const LifeMotion._();

  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
  static const emphasised = Duration(milliseconds: 280);
  static const celebrate = Duration(milliseconds: 420);

  static const microCurve = Curves.easeOutCubic;
  static const standardCurve = Curves.easeOutCubic;
  static const emphasisedCurve = Cubic(0.2, 0, 0, 1);
  // Flutter's Curves has no built-in spring; approximated with a curve
  // tuned to a similar stiffness/damping feel for the celebrate moment.
  static const celebrateCurve = Curves.elasticOut;

  static const stagger = Duration(milliseconds: 24);
  static const staggerMaxItems = 6;
  static const listAnimateMaxItems = 12;

  /// Reduced-motion replacement: a flat opacity fade, no stagger.
  static const reducedMotionFade = Duration(milliseconds: 100);
}
