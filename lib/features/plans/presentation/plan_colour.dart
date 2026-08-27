import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §7.2: `colour` is "a domain colour or accent name" — resolve whichever
/// it is, falling back to the `plans` domain colour if it's neither (e.g.
/// unset).
LifeAccentColor resolvePlanColour(BuildContext context, String? name) {
  final colors = context.colors;
  if (name != null) {
    final domainTable = LifeDomainColors.all(colors.brightness);
    if (domainTable.containsKey(name)) return domainTable[name]!;
    for (final accentName in LifeAccentName.values) {
      if (accentName.name == name) {
        return LifeAccents.of(accentName, colors.brightness);
      }
    }
  }
  return colors.domain('plans');
}
