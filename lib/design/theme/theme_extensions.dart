import 'package:flutter/material.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/typography.dart';

/// Ergonomic access to the design tokens from a [BuildContext], so feature
/// code never touches hex values or raw `TextStyle`s directly (CLAUDE.md
/// rule 5): `context.colors.neutrals.ink`, `context.textStyles.body`.
extension LifeThemeContext on BuildContext {
  LifeColors get colors => Theme.of(this).extension<LifeColors>()!;

  LifeTextStyles get textStyles => Theme.of(this).extension<LifeTextStyles>()!;
}
