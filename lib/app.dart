import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/design/dev_gallery/dev_component_gallery_screen.dart';
import 'package:life_os/design/theme/dark_theme.dart';
import 'package:life_os/design/theme/light_theme.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

class LifeOsApp extends StatelessWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.instance.appName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      home: const _NotBuiltYetScreen(),
    );
  }
}

/// Honest placeholder for the project-setup milestone (M1). There is no
/// feature UI yet — the navigation shell lands in M3. This screen exists so
/// the app never presents fake or stub functionality (CLAUDE.md rule 1).
///
/// The one exception is the debug-only entry point into
/// [DevComponentGalleryScreen] (M2 DoD) — gated on [kDebugMode] so it can
/// never reach a release build, not even accidentally.
class _NotBuiltYetScreen extends StatelessWidget {
  const _NotBuiltYetScreen();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(LifeSpace.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConfig.instance.appName,
                style: textStyles.title1.copyWith(color: colors.neutrals.ink),
              ),
              const SizedBox(height: LifeSpace.s12),
              Text(
                'Milestone 1 — project setup. Nothing is built yet.',
                textAlign: TextAlign.center,
                style: textStyles.body.copyWith(color: colors.neutrals.ink2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const DevComponentGalleryScreen()),
              ),
              label: const Text('Components'),
              icon: const Icon(Icons.palette_outlined),
            )
          : null,
    );
  }
}
