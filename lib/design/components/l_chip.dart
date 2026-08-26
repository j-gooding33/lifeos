import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A pill-shaped filter/tag chip (§2.7).
class LChip extends StatelessWidget {
  const LChip({
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = selected ? colors.accent.soft : colors.neutrals.surfaceAlt;
    final foreground = selected ? colors.accent.base : colors.neutrals.ink2;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LifeRadius.pill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(LifeRadius.pill)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: foreground),
                    const SizedBox(width: LifeSpace.s8),
                  ],
                  Text(label, style: context.textStyles.subhead.copyWith(color: foreground)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
