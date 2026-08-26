import 'package:flutter/material.dart';

/// Elevation shadows (§2.4). Dark mode uses none — elevation there is
/// conveyed by `surface` → `surfaceAlt` lightness steps plus a 1px border
/// top highlight instead, handled by the components that use this token.
class LifeShadows {
  const LifeShadows._();

  static const _raisedLight = [
    BoxShadow(color: Color(0x0A10111A), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F10111A), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const _floatingLight = [
    BoxShadow(color: Color(0x2410111A), offset: Offset(0, 8), blurRadius: 28),
  ];

  static List<BoxShadow> raised(Brightness brightness) =>
      brightness == Brightness.dark ? const [] : _raisedLight;

  static List<BoxShadow> floating(Brightness brightness) =>
      brightness == Brightness.dark ? const [] : _floatingLight;
}
