import 'package:flutter/material.dart';
import 'package:life_os/design/theme/theme_extensions.dart';

/// A grid of intensity cells (§2.7), e.g. a plan's 12-week completion
/// heatmap. Intensity is encoded as opacity *and* a hairline border on
/// empty cells, never colour alone (§2.9).
class LHeatmapGrid extends StatelessWidget {
  const LHeatmapGrid({
    required this.values,
    this.columns = 12,
    this.cellSize = 12,
    this.gap = 3,
    super.key,
  });

  /// Each value is 0.0 (nothing) – 1.0 (fully done), or null for "no data".
  final List<double?> values;
  final int columns;
  final double cellSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final value in values)
          Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: value == null
                  ? Colors.transparent
                  : colors.accent.base.withValues(alpha: 0.15 + 0.85 * value),
              border: value == null ? Border.all(color: colors.neutrals.border) : null,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
