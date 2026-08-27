import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:life_os/features/settings/application/settings_providers.dart';

/// Settings → Display → Theme. Four complete visual identities — palette,
/// accent and type all change together, never independently. No separate
/// light/dark toggle: each scheme carries its own brightness.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final current = ref.watch(currentThemeSchemeProvider).value ?? LifeThemeScheme.afterHours;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          const LSectionHeader(title: 'Theme'),
          const SizedBox(height: LifeSpace.s8),
          for (final scheme in LifeThemeScheme.values) ...[
            _ThemeOptionCard(
              scheme: scheme,
              selected: scheme == current,
              onTap: () => setThemeScheme(ref, scheme),
            ),
            const SizedBox(height: LifeSpace.s12),
          ],
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({required this.scheme, required this.selected, required this.onTap});

  final LifeThemeScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = LifeColors.forScheme(scheme);

    return LCard(
      onTap: onTap,
      child: Row(
        children: [
          _SwatchStrip(preview: preview),
          const SizedBox(width: LifeSpace.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scheme.label, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                const SizedBox(height: LifeSpace.s4),
                Text(scheme.description, style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2)),
              ],
            ),
          ),
          const SizedBox(width: LifeSpace.s8),
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            color: selected ? colors.accent.base : colors.neutrals.ink3,
          ),
        ],
      ),
    );
  }
}

/// A tiny fixed-palette preview — bg/surface/ink/accent — independent of
/// the *current* app theme, since the whole point is showing what the
/// *other* schemes look like.
class _SwatchStrip extends StatelessWidget {
  const _SwatchStrip({required this.preview});

  final LifeColors preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: preview.neutrals.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: preview.neutrals.border),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: preview.accent.base, shape: BoxShape.circle),
      ),
    );
  }
}
