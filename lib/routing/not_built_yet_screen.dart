import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

/// The honest placeholder every not-yet-built route in §3.2 renders
/// (CLAUDE.md rule 1: no stub buttons, no "coming soon" screens that look
/// functional — just a plain statement of fact).
class NotBuiltYetScreen extends StatelessWidget {
  const NotBuiltYetScreen({required this.featureName, this.showDevGalleryLink = false, super.key});

  final String featureName;

  /// Only ever `true` on the Home route's registration in `router.dart`,
  /// and only renders anything when [kDebugMode] too — the M2 component
  /// gallery needs exactly one discoverable, debug-only entry point.
  final bool showDevGalleryLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text(featureName)),
      body: LEmptyState(
        icon: Icons.construction_outlined,
        title: 'Not built yet',
        message: "$featureName is on the roadmap but hasn't shipped.",
      ),
      floatingActionButton: showDevGalleryLink && kDebugMode
          ? Padding(
              padding: const EdgeInsets.only(bottom: LifeSpace.s16),
              child: LButton(
                label: 'Component gallery',
                variant: LButtonVariant.tonal,
                onPressed: () => context.push(Routes.devComponentGallery),
              ),
            )
          : null,
    );
  }
}
