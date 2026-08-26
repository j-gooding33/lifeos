import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A vertical rail with a dot per item and a filled segment for elapsed
/// time (§2.7). Runs alongside a time-ordered list (Home's schedule card,
/// the Calendar day view, a Plan detail timeline).
class LDayRail extends StatelessWidget {
  const LDayRail({
    required this.itemFractions,
    required this.height,
    this.progressFraction,
    this.width = 2,
    super.key,
  });

  /// Each item's position along the rail, 0.0 (top) – 1.0 (bottom).
  final List<double> itemFractions;

  /// How much of the rail is "elapsed", 0.0–1.0. Null hides the fill
  /// (e.g. a day fully in the past or fully in the future).
  final double? progressFraction;

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 12,
      height: height,
      child: CustomPaint(
        painter: _DayRailPainter(
          itemFractions: itemFractions,
          progressFraction: progressFraction,
          railWidth: width,
          trackColor: colors.neutrals.border,
          elapsedColor: colors.accent.base,
          dotColor: colors.neutrals.ink3,
        ),
      ),
    );
  }
}

class _DayRailPainter extends CustomPainter {
  _DayRailPainter({
    required this.itemFractions,
    required this.progressFraction,
    required this.railWidth,
    required this.trackColor,
    required this.elapsedColor,
    required this.dotColor,
  });

  final List<double> itemFractions;
  final double? progressFraction;
  final double railWidth;
  final Color trackColor;
  final Color elapsedColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final track = Paint()
      ..color = trackColor
      ..strokeWidth = railWidth;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), track);

    final progress = progressFraction;
    if (progress != null && progress > 0) {
      final fill = Paint()
        ..color = elapsedColor
        ..strokeWidth = railWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * progress.clamp(0, 1)), fill);
    }

    final dotPaint = Paint()..color = dotColor;
    for (final fraction in itemFractions) {
      canvas.drawCircle(Offset(x, size.height * fraction.clamp(0, 1)), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DayRailPainter oldDelegate) =>
      oldDelegate.itemFractions != itemFractions ||
      oldDelegate.progressFraction != progressFraction;
}
