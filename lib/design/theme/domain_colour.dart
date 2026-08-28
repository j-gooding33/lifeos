import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';

/// Resolves a Plan/Project/Goal `colour` field — "a domain colour or
/// accent name" (§7.2, §11.2, §12.2 all use the same convention) — to a
/// real [LifeAccentColor]. Lives here, not in any one feature, so
/// `plans/`, `tasks/`'s Projects and Goals can each call it without
/// crossing a feature boundary (rule 4): before this, each had its own
/// byte-for-byte copy differing only in [fallbackDomain].
LifeAccentColor resolveDomainColour(BuildContext context, String? name, {required String fallbackDomain}) {
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
  return colors.domain(fallbackDomain);
}
