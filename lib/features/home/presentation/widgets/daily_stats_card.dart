import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `dailyStats` — 3 counters: tasks done, plans done, streak days.
class DailyStatsCard extends StatelessWidget {
  const DailyStatsCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LCard(
      onTap: () => context.push(Routes.stats),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          LStat(value: '${snapshot.doneToday}', caption: 'tasks'),
          LStat(value: '${snapshot.plansCompletedToday}', caption: 'plans'),
          LStat(value: '${snapshot.currentStreakDays}', caption: 'streak'),
        ],
      ),
    );
  }
}
