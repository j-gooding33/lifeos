import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

enum LButtonVariant { filled, tonal, plain, destructive }

/// The app's button (§2.7) with four variants sharing one shape and one
/// touch-target floor.
class LButton extends StatelessWidget {
  const LButton({
    required this.label,
    required this.onPressed,
    this.variant = LButtonVariant.filled,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final LButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final danger = colors.semantic('danger');

    late Color background;
    late Color foreground;
    switch (variant) {
      case LButtonVariant.filled:
        background = colors.accent.base;
        foreground = colors.accent.on;
      case LButtonVariant.tonal:
        background = colors.accent.soft;
        foreground = colors.accent.base;
      case LButtonVariant.plain:
        background = Colors.transparent;
        foreground = colors.accent.base;
      case LButtonVariant.destructive:
        background = danger.base;
        foreground = danger.on;
    }

    final disabled = onPressed == null;
    if (disabled) {
      background = variant == LButtonVariant.plain ? background : colors.neutrals.surfaceAlt;
      foreground = colors.neutrals.ink3;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(LifeRadius.control),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(LifeRadius.control),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s20, vertical: LifeSpace.s12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: LifeSpace.s8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: context.textStyles.bodyStrong.copyWith(color: foreground),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
