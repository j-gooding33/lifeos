import 'package:flutter/material.dart';
import 'package:life_os/design/theme/domain_colour.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §12.2: `colour` is "a domain colour or accent name," same convention
/// Plans/Projects use. Falls back to the `goals` domain colour.
LifeAccentColor resolveGoalColour(BuildContext context, String? name) {
  return resolveDomainColour(context, name, fallbackDomain: 'goals');
}
