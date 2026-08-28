import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/motion.dart';

/// A linear progress bar on a `surfaceSunken` track (§2.7).
class LProgressBar extends StatelessWidget {
  const LProgressBar({required this.value, this.semanticLabel, super.key});

  /// 0.0–1.0
  final double value;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: double.infinity,
          height: 8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: colors.neutrals.surfaceSunken),
              TweenAnimationBuilder<double>(
                duration: LifeMotion.standard,
                curve: LifeMotion.standardCurve,
                tween: Tween(begin: 0, end: value.clamp(0, 1)),
                builder: (context, animatedValue, child) {
                  return FractionallySizedBox(
                    widthFactor: animatedValue,
                    alignment: Alignment.centerLeft,
                    child: child,
                  );
                },
                child: ColoredBox(color: colors.accent.base),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
