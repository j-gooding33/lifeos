import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A circular progress ring (§2.7), e.g. Home's habit rings.
class LProgressRing extends StatelessWidget {
  const LProgressRing({
    required this.value,
    this.size = 44,
    this.strokeWidth = 4,
    this.child,
    this.semanticLabel,
    super.key,
  });

  /// 0.0–1.0
  final double value;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                value: value.clamp(0, 1),
                trackColor: colors.neutrals.surfaceSunken,
                progressColor: colors.accent.base,
                strokeWidth: strokeWidth,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double value;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas
      ..drawCircle(center, radius, track)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        progress,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
