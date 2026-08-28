import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:life_os/core/utils/money_format.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/spacing.dart';

class CategorySlice {
  const CategorySlice({required this.label, required this.amountMinor});

  final String label;
  final int amountMinor;
}

/// §22.2's "category donut" — hand-drawn with `CustomPainter`, not a chart
/// package (this session's established convention: the rating-distribution
/// bar and the habit heatmap took the same approach).
class CategoryDonut extends StatelessWidget {
  const CategoryDonut({required this.slices, required this.currency, super.key});

  final List<CategorySlice> slices;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = slices.fold<int>(0, (sum, s) => sum + s.amountMinor);
    if (total == 0 || slices.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(child: Text('No spending yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2))),
      );
    }
    final sliceColours = [for (var i = 0; i < slices.length; i++) LifeAccents.of(LifeAccentName.values[i % LifeAccentName.values.length], colors.brightness)];

    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total, colours: sliceColours, trackColour: colors.neutrals.surfaceSunken),
            child: Center(
              child: Text(formatMoney(total, currency), style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink), textAlign: TextAlign.center),
            ),
          ),
        ),
        const SizedBox(width: LifeSpace.s20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < slices.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: sliceColours[i].base, shape: BoxShape.circle)),
                      const SizedBox(width: LifeSpace.s8),
                      Expanded(
                        child: Text(
                          slices[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                        ),
                      ),
                      const SizedBox(width: LifeSpace.s8),
                      Text(formatMoney(slices[i].amountMinor, currency), style: context.textStyles.caption.copyWith(color: colors.neutrals.ink)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.total, required this.colours, required this.trackColour});

  final List<CategorySlice> slices;
  final int total;
  final List<LifeAccentColor> colours;
  final Color trackColour;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);

    final track = Paint()
      ..color = trackColour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(inset, 0, 2 * math.pi, false, track);

    var startAngle = -math.pi / 2;
    for (var i = 0; i < slices.length; i++) {
      final sweep = (slices[i].amountMinor / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colours[i].base
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(inset, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) => oldDelegate.slices != slices || oldDelegate.total != total;
}
