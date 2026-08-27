import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/colors.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// Next 7 days, one line per day with counts (§5.3).
class UpcomingCard extends StatelessWidget {
  const UpcomingCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Upcoming'),
          const SizedBox(height: LifeSpace.s8),
          for (var i = 1; i <= 7; i++) _dayRow(context, colors, today.addDays(i)),
        ],
      ),
    );
  }

  Widget _dayRow(BuildContext context, LifeColors colors, CivilDate date) {
    final count = snapshot.upcomingByDay[date.toIso()] ?? 0;
    return InkWell(
      onTap: () => context.push(Routes.homeDay.replaceFirst(':date', date.toIso())),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _weekdayNames[date.isoWeekday - 1],
                style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
              ),
            ),
            Text(
              count == 0 ? '—' : '$count',
              style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2),
            ),
          ],
        ),
      ),
    );
  }
}
