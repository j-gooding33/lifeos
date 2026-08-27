import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §11.2: `colour` is "a domain colour or accent name," same convention
/// Plans uses (see `lib/features/plans/presentation/plan_colour.dart`,
/// not imported here — that would cross the plans/tasks feature boundary,
/// rule 4). Falls back to the `tasks` domain colour, since Projects lives
/// under the Tasks tab.
LifeAccentColor resolveProjectColour(BuildContext context, String? name) {
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
  return colors.domain('tasks');
}
