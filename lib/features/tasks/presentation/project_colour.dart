import 'package:flutter/material.dart';
import 'package:life_os/design/theme/domain_colour.dart';
import 'package:life_os/design/tokens/colors.dart';

/// §11.2: `colour` is "a domain colour or accent name," same convention
/// Plans/Goals use. Falls back to the `tasks` domain colour, since
/// Projects lives under the Tasks tab.
LifeAccentColor resolveProjectColour(BuildContext context, String? name) {
  return resolveDomainColour(context, name, fallbackDomain: 'tasks');
}
