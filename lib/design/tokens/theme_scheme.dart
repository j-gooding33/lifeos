import 'package:flutter/material.dart';

/// A complete, named visual identity — palette, accent and type all change
/// together, not three independent pickers. Distinct from `LifeAccentName`
/// (`colors.dart`), which tags an individual plan with one of eight colours
/// and is unaffected by this — see DECISIONS.md.
enum LifeThemeScheme { afterHours, ledger, fieldnotes, signal }

extension LifeThemeSchemeInfo on LifeThemeScheme {
  /// After Hours is the only dark scheme; the other three are light. There
  /// is no separate light/dark toggle — picking a scheme picks a brightness.
  Brightness get brightness => this == LifeThemeScheme.afterHours ? Brightness.dark : Brightness.light;

  String get label => switch (this) {
    LifeThemeScheme.afterHours => 'After Hours',
    LifeThemeScheme.ledger => 'Ledger',
    LifeThemeScheme.fieldnotes => 'Fieldnotes',
    LifeThemeScheme.signal => 'Signal',
  };

  String get description => switch (this) {
    LifeThemeScheme.afterHours => 'Dark, ambient, premium — soft coral glow on charcoal-navy.',
    LifeThemeScheme.ledger => 'Cool, structured, fintech-precise — hairlines and tabular numerals.',
    LifeThemeScheme.fieldnotes => 'Warm and tactile — stone grey, deep moss, a serif display face.',
    LifeThemeScheme.signal => 'Stark and editorial — flat white, sharp corners, one loud blue.',
  };
}
