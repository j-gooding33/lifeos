import 'package:flutter/material.dart';
import 'package:life_os/design/theme/domain_colour.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §7.2: `colour` is "a domain colour or accent name" — resolve whichever
/// it is, falling back to the `plans` domain colour if it's neither (e.g.
/// unset).
LifeAccentColor resolvePlanColour(BuildContext context, String? name) {
  return resolveDomainColour(context, name, fallbackDomain: 'plans');
}
