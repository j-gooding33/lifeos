import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `activity` — a 14-day completion sparkline. Hand-rolled with
/// `Container` heights, same as the Library rating-distribution bars and
/// `LHeatmapGrid` — one more bar chart doesn't justify a charting
/// dependency (see DECISIONS.md).
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  static const _maxBarHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final scores = snapshot.activityLast14Days;
    if (scores.every((c) => c == 0)) return const SizedBox.shrink();

    final maxCount = scores.reduce((a, b) => a > b ? a : b);

    return LCard(
      onTap: () => context.push(Routes.stats),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Activity'),
          const SizedBox(height: LifeSpace.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < scores.length; i++) ...[
                if (i > 0) const SizedBox(width: LifeSpace.s4),
                Expanded(child: _bar(context, scores[i], maxCount)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, int count, int maxCount) {
    final colors = context.colors;
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = count == 0 ? 2.0 : (fraction * _maxBarHeight).clamp(4.0, _maxBarHeight);
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: count == 0 ? colors.neutrals.surfaceAlt : colors.accent.base,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
