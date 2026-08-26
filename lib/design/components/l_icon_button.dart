import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// An icon-only button (§2.7) with a mandatory [semanticLabel] — every
/// icon-only control must have one (§2.9).
class LIconButton extends StatelessWidget {
  const LIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        icon: Icon(icon, color: colors.neutrals.ink),
        tooltip: semanticLabel,
        onPressed: onPressed,
      ),
    );
  }
}
