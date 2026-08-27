import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_heatmap_grid.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/habit_stats.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/rule_description.dart';
import 'package:life_os/features/plans/presentation/widgets/plan_actions_menu.dart';
import 'package:life_os/routing/routes.dart';

/// §13.2: current streak, best streak, this month's completion %, a
/// full-year heatmap, and a month calendar. The calendar reuses
/// `PlanCalendarScreen` (§8.2) unchanged — a habit's calendar is a plan's
/// calendar, no separate implementation.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({required this.habitId, super.key});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncPlan = ref.watch(planByIdProvider(habitId));
    return asyncPlan.when(
      loading: () => const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const LErrorState(message: "Couldn't load this habit.")),
      data: (plan) {
        if (plan == null) {
          return Scaffold(appBar: AppBar(), body: const LErrorState(message: 'This habit no longer exists.'));
        }
        return Scaffold(
          backgroundColor: colors.neutrals.bg,
          appBar: AppBar(
            title: Text(plan.title),
            actions: [
              Builder(
                builder: (buttonContext) => IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Habit actions',
                  onPressed: () {
                    final box = buttonContext.findRenderObject()! as RenderBox;
                    final position = box.localToGlobal(box.size.center(Offset.zero));
                    showPlanActionsMenu(context: context, ref: ref, plan: plan, position: position, onDeleted: () => context.pop());
                  },
                ),
              ),
            ],
          ),
          body: _HabitDetailBody(plan: plan),
        );
      },
    );
  }
}

class _HabitDetailBody extends ConsumerWidget {
  const _HabitDetailBody({required this.plan});

  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final planColour = resolvePlanColour(context, plan.colour);
    final today = CivilDate.fromDateTime(DateTime.now());
    final yearStart = today.addDays(-364);
    final asyncStats = ref.watch(planStatsProvider(plan.id));
    final asyncYear = ref.watch(planOccurrencesInRangeProvider(plan.id, yearStart, today));

    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: planColour.soft, child: Icon(planIconFor(plan.icon), color: planColour.base)),
            const SizedBox(width: LifeSpace.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(describeRule(plan.rule), style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2)),
                  if (plan.target != null)
                    Text(
                      'Target: ${plan.target!.value % 1 == 0 ? plan.target!.value.toInt() : plan.target!.value} ${plan.target!.unit}',
                      style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: LifeSpace.cardGap),
        asyncStats.when(
          loading: () => const LLoadingShimmer(height: 80),
          error: (error, stack) => const SizedBox.shrink(),
          data: (stats) => LCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LStat(value: '${stats.streak}', caption: 'STREAK'),
                LStat(value: '${stats.bestStreak}', caption: 'BEST'),
                asyncYear.when(
                  loading: () => const LStat(value: '—', caption: 'THIS MONTH'),
                  error: (error, stack) => const LStat(value: '—', caption: 'THIS MONTH'),
                  data: (occurrences) {
                    final rate = computeMonthCompletionRate(occurrences, today: today);
                    return LStat(value: rate == null ? '—' : '${(rate * 100).round()}%', caption: 'THIS MONTH');
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: LifeSpace.cardGap),
        LCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LSectionHeader(title: 'Past year'),
              const SizedBox(height: LifeSpace.s12),
              asyncYear.when(
                loading: () => const LLoadingShimmer(height: 120),
                error: (error, stack) => const SizedBox.shrink(),
                data: (occurrences) => LHeatmapGrid(
                  values: computeYearHeatmap(occurrences, today: today, habitStart: plan.startDate),
                  columns: 7,
                  cellSize: 9,
                  gap: 2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LifeSpace.cardGap),
        LButton(
          label: 'Month calendar',
          variant: LButtonVariant.tonal,
          onPressed: () => context.push(Routes.planCalendar.replaceFirst(':id', plan.id)),
        ),
      ],
    );
  }
}
