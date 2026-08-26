import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 2.x contrast ratio between two colours, from 1.0 (no contrast) to
/// 21.0 (black on white). Used by the §2.9 accessibility floor: body text
/// needs ≥4.5, large text and non-text indicators need ≥3.0.
double contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
