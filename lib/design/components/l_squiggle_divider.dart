import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A subtle sine-wave divider (drawn, not an asset) — used where a plain
/// straight rule would read as a hard section break but the content on
/// both sides is really one continuous list (e.g. Tasks' Today tab: today's
/// items, then everything beyond today).
class LSquiggleDivider extends StatelessWidget {
  const LSquiggleDivider({this.height = 10, this.waveLength = 14, this.amplitude = 2, super.key});

  final double height;
  final double waveLength;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _SquigglePainter(
          // Low-opacity outline colour (§ token) — a hint of a divider, not
          // a hard rule.
          color: colors.neutrals.border.withValues(alpha: 0.55),
          waveLength: waveLength,
          amplitude: amplitude,
        ),
      ),
    );
  }
}

class _SquigglePainter extends CustomPainter {
  const _SquigglePainter({required this.color, required this.waveLength, required this.amplitude});

  final Color color;
  final double waveLength;
  final double amplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;
    final path = Path()..moveTo(0, midY);
    const step = 2.0;
    for (var x = step; x <= size.width; x += step) {
      final y = midY + amplitude * math.sin(2 * math.pi * x / waveLength);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SquigglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.waveLength != waveLength || oldDelegate.amplitude != amplitude;
}
