import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §12.2: same "domain colour or accent name" convention as Plans'/
/// Projects' own copies of this lookup (not imported — that would cross
/// a feature boundary, rule 4; see DECISIONS.md on why a third copy is a
/// candidate for consolidation, not done yet). Falls back to the `goals`
/// domain colour.
LifeAccentColor resolveGoalColour(BuildContext context, String? name) {
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
  return colors.domain('goals');
}
