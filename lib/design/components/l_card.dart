import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/shadows.dart';
import 'package:life_os/design/tokens/spacing.dart';

/// A raised surface container (§2.7). The base building block most other
/// components sit on top of.
class LCard extends StatelessWidget {
  const LCard({
    required this.child,
    this.padding = const EdgeInsets.all(LifeSpace.cardPadding),
    this.onTap,
    this.large = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = large ? 20.0 : 16.0;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.neutrals.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: LifeShadows.raised(Theme.of(context).brightness),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: colors.neutrals.border)
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
