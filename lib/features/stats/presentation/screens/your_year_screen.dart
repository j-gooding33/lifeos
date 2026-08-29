import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/stats/application/stats_providers.dart';
import 'package:life_os/features/stats/presentation/widgets/year_grid.dart';
import 'package:life_os/routing/routes.dart';

/// §21: "the signature screen." The grid render satisfies §21.3's "not 365
/// widgets" via `YearGrid`'s `CustomPainter`. "Share your year" (PNG
/// export) isn't built — see DECISIONS.md.
class YourYearScreen extends ConsumerStatefulWidget {
  const YourYearScreen({super.key});

  @override
  ConsumerState<YourYearScreen> createState() => _YourYearScreenState();
}

class _YourYearScreenState extends ConsumerState<YourYearScreen> {
  late var _year = DateTime.now().year;
  var _compareToLastYear = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final yearStart = CivilDate(_year, 1, 1);
    final yearEnd = CivilDate(_year, 12, 31);
    final asyncScores = ref.watch(dailyActivityScoresProvider(yearStart, yearEnd));
    final asyncMilestoneDates = ref.watch(datesWithCompletedMilestoneProvider(yearStart, yearEnd));
    final asyncPeriod = ref.watch(periodStatsProvider(yearStart, yearEnd));
    final asyncLastYearScores = _compareToLastYear
        ? ref.watch(dailyActivityScoresProvider(CivilDate(_year - 1, 1, 1), CivilDate(_year - 1, 12, 31)))
        : null;

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _year--)),
            Text('$_year'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _year >= DateTime.now().year ? null : () => setState(() => _year++),
            ),
          ],
        ),
      ),
      body: asyncScores.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text("Couldn't load this year.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (scores) {
          final activeDays = scores.values.where((s) => s > 0).length;
          final longestStreak = _longestStreak(scores.keys.toSet());
          final totalCompletions = asyncPeriod.value == null
              ? null
              : asyncPeriod.value!.tasksCompleted + asyncPeriod.value!.occurrencesCompleted;

          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LStat(value: '$activeDays', caption: 'days'),
                  LStat(value: totalCompletions == null ? '—' : '$totalCompletions', caption: 'done'),
                  LStat(value: '$longestStreak', caption: 'streak'),
                ],
              ),
              const SizedBox(height: LifeSpace.cardGap),
              YearGrid(
                year: _year,
                activityScores: scores,
                milestoneDates: asyncMilestoneDates.value ?? const {},
                onSelectDay: (date) => context.push(Routes.homeDay.replaceFirst(':date', date.toIso())),
                lastYearScores: asyncLastYearScores?.value,
              ),
              const SizedBox(height: LifeSpace.s16),
              const _Legend(),
              const SizedBox(height: LifeSpace.s8),
              LListTile(
                title: 'Compare to last year',
                subtitle: "Overlays a thin line of ${_year - 1}'s weekly totals.",
                trailing: Switch(
                  value: _compareToLastYear,
                  onChanged: (value) => setState(() => _compareToLastYear = value),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _longestStreak(Set<CivilDate> activeDates) {
    if (activeDates.isEmpty) return 0;
    final sorted = activeDates.toList()..sort((a, b) => a.compareTo(b));
    var longest = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (CivilDate.daysBetween(sorted[i - 1], sorted[i]) == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  static const _opacities = [0.0, 0.18, 0.42, 0.68, 1.0];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Less', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
        const SizedBox(width: LifeSpace.s8),
        for (final opacity in _opacities)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: opacity == 0 ? colors.neutrals.surfaceSunken : colors.accent.base.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: LifeSpace.s8),
        Text('More', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
      ],
    );
  }
}
