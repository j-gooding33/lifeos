import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/preferences/preference_toggle.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/insight.dart';
import 'package:life_os/data/repositories/models/period_stats.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_progress_bar.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/stats/application/stats_providers.dart';
import 'package:life_os/routing/routes.dart';

enum _Period { today, week, month, year, allTime }

const _periodLabels = {_Period.today: 'Today', _Period.week: 'Week', _Period.month: 'Month', _Period.year: 'Year', _Period.allTime: 'All time'};
const _periodPrefKey = 'stats.period';

(CivilDate, CivilDate) _rangeFor(_Period period, CivilDate today) {
  switch (period) {
    case _Period.today:
      return (today, today);
    case _Period.week:
      return (today.startOfWeek(), today.startOfWeek().addDays(6));
    case _Period.month:
      final start = CivilDate(today.year, today.month, 1);
      return (start, start.addMonths(1).addDays(-1));
    case _Period.year:
      return (CivilDate(today.year, 1, 1), CivilDate(today.year, 12, 31));
    case _Period.allTime:
      return (const CivilDate(2000, 1, 1), today);
  }
}

/// §20.2. Charts are hand-built (LProgressBar/LStat), not `fl_chart` — same
/// no-new-chart-dependency call this session already made for the rating-
/// distribution bar, the habit heatmap and Finance's donut. Insights
/// (§20.3) are three fixed deterministic checks, not a general engine —
/// see `StatsRepository.insights`. The "view as table"/accessible-summary
/// affordances aren't built; see DECISIONS.md. Only 5 of the spec's 9
/// domain cards are here (Tasks, Plans & Habits, Goals, Library, Finance)
/// — Projects and Study
/// are deferred, not silently dropped.
class StatsOverviewScreen extends ConsumerWidget {
  const StatsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());
    final periodName = ref.watch(stringPreferenceProvider(_periodPrefKey)).value;
    final period = _Period.values.firstWhere((p) => p.name == periodName, orElse: () => _Period.week);
    final (from, to) = _rangeFor(period, today);
    final asyncStats = ref.watch(periodStatsProvider(from, to));
    final insights = ref.watch(insightsProvider).value ?? const [];

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_view_month), tooltip: 'Your Year', onPressed: () => context.push(Routes.statsYear)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          if (insights.isNotEmpty) ...[_InsightsCard(insights: insights), const SizedBox(height: LifeSpace.cardGap)],
          LSegmented<_Period>(
            segments: _periodLabels,
            selected: period,
            onChanged: (value) => setStringPreference(ref, _periodPrefKey, value.name),
          ),
          const SizedBox(height: LifeSpace.cardGap),
          asyncStats.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text("Couldn't load stats.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
            data: (stats) => _StatsBody(stats: stats),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final PeriodStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LStat(value: '${stats.tasksCompleted}', caption: 'tasks'),
            LStat(value: '${stats.occurrencesCompleted}', caption: 'plans'),
            LStat(value: '${stats.filmsWatched + stats.booksFinished}', caption: 'media'),
            LStat(value: '${stats.journalDaysWritten}', caption: 'journal'),
          ],
        ),
        const SizedBox(height: LifeSpace.cardGap),
        LCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LSectionHeader(title: 'Plans & habits'),
              const SizedBox(height: LifeSpace.s12),
              if (stats.occurrenceCompletionRate == null)
                Text('Nothing scheduled yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2))
              else ...[
                Row(
                  children: [
                    Expanded(child: Text('Completion rate', style: context.textStyles.body.copyWith(color: colors.neutrals.ink))),
                    Text('${(stats.occurrenceCompletionRate! * 100).round()}%', style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                  ],
                ),
                const SizedBox(height: LifeSpace.s4),
                LProgressBar(value: stats.occurrenceCompletionRate!, semanticLabel: 'Plan completion rate'),
                const SizedBox(height: LifeSpace.s8),
                Text(
                  '${stats.habitsCompleted} habit check-ins · ${stats.occurrencesMissed} missed · ${stats.occurrencesSkipped} skipped',
                  style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: LifeSpace.cardGap),
        _LinkCard(
          title: 'Goals',
          subtitle: '${stats.goalContributions} contribution${stats.goalContributions == 1 ? '' : 's'} logged',
          icon: Icons.flag_outlined,
          onTap: () => context.push(Routes.goals),
        ),
        const SizedBox(height: LifeSpace.s12),
        _LinkCard(
          title: 'Library',
          subtitle: '${stats.filmsWatched} film${stats.filmsWatched == 1 ? '' : 's'} watched · ${stats.booksFinished} book${stats.booksFinished == 1 ? '' : 's'} finished',
          icon: Icons.movie_outlined,
          onTap: () => context.push(Routes.library),
        ),
        const SizedBox(height: LifeSpace.s12),
        _LinkCard(
          title: 'Finance',
          subtitle: 'Monthly spend, budgets and category breakdown',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => context.push(Routes.finance),
        ),
      ],
    );
  }
}

/// §20.3. Hidden entirely (not an empty-state placeholder) until at least
/// one insight clears its own sample-size and threshold gates — an empty
/// "not enough data yet" card would say nothing a first-time user needs to
/// hear and would just be clutter for everyone else.
class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.insights});

  final List<Insight> insights;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Insights'),
          const SizedBox(height: LifeSpace.s12),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: colors.accent.base),
                  const SizedBox(width: LifeSpace.s8),
                  Expanded(child: Text(insight.text, style: context.textStyles.body.copyWith(color: colors.neutrals.ink))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: colors.accent.base),
          const SizedBox(width: LifeSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                Text(subtitle, style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.neutrals.ink3),
        ],
      ),
    );
  }
}
