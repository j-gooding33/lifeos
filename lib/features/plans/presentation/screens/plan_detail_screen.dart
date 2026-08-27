import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_heatmap_grid.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/occurrence_status_style.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/rule_description.dart';
import 'package:life_os/features/plans/presentation/widgets/occurrence_sheet.dart';
import 'package:life_os/features/plans/presentation/widgets/plan_actions_menu.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(CivilDate date) =>
    '${_weekdayNames[date.isoWeekday - 1]} ${date.day} ${_monthNames[date.month - 1]}';

/// §7.5. Stats strip, 12-week heatmap, and an Upcoming/History list split
/// at today. The `mediaType != none` content slot ("+ choose a film") is
/// deferred — there's no Library to pick from until M11/M12 — so occurrence
/// rows never offer it, per rule 1 (no dead affordances).
class PlanDetailScreen extends ConsumerStatefulWidget {
  const PlanDetailScreen({required this.planId, super.key});

  final String planId;

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  var _materialisedOnce = false;
  var _historyLimit = 20;

  @override
  Widget build(BuildContext context) {
    final asyncPlan = ref.watch(planByIdProvider(widget.planId));
    return asyncPlan.when(
      loading: () =>
          const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: const LErrorState(message: "Couldn't load this plan."),
      ),
      data: (plan) {
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const LErrorState(message: 'This plan no longer exists.'),
          );
        }
        // §9.5 trigger: "plan detail open."
        if (!_materialisedOnce) {
          _materialisedOnce = true;
          Future.microtask(
            () => ref.read(planRepositoryProvider).ensureMaterialised(plan),
          );
        }
        return _buildScaffold(context, plan);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, AppPlan plan) {
    final colors = context.colors;
    final planColour = resolvePlanColour(context, plan.colour);
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Plan actions',
              onPressed: () {
                final box = buttonContext.findRenderObject()! as RenderBox;
                final position = box.localToGlobal(
                  box.size.center(Offset.zero),
                );
                showPlanActionsMenu(
                  context: context,
                  ref: ref,
                  plan: plan,
                  position: position,
                  onDeleted: () => Navigator.of(context).pop(),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: planColour.soft,
                child: Icon(planIconFor(plan.icon), color: planColour.base),
              ),
              const SizedBox(width: LifeSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.timeOfDay == null
                          ? describeRule(plan.rule)
                          : '${describeRule(plan.rule)} · ${plan.timeOfDay}',
                      style: context.textStyles.mono.copyWith(
                        color: colors.neutrals.ink2,
                      ),
                    ),
                    Text(
                      'Since ${_formatDate(plan.startDate)}',
                      style: context.textStyles.caption.copyWith(
                        color: colors.neutrals.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LifeSpace.cardGap),
          _StatsCard(planId: plan.id),
          const SizedBox(height: LifeSpace.cardGap),
          _UpcomingSection(plan: plan),
          const SizedBox(height: LifeSpace.cardGap),
          _HistorySection(
            plan: plan,
            limit: _historyLimit,
            onLoadMore: () => setState(() => _historyLimit += 20),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  const _StatsCard({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(planStatsProvider(planId));
    return asyncStats.when(
      loading: () => const LLoadingShimmer(height: 100),
      error: (error, stack) => const SizedBox.shrink(),
      data: (stats) => LCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LStat(value: '${stats.done}', caption: 'done'),
                LStat(value: '${(stats.rate * 100).round()}%', caption: 'rate'),
                LStat(value: '${stats.streak}', caption: 'streak'),
                LStat(value: '${stats.missed}', caption: 'missed'),
              ],
            ),
            const SizedBox(height: LifeSpace.s16),
            LHeatmapGrid(values: stats.weeklyHeatmap),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSection extends ConsumerWidget {
  const _UpcomingSection({required this.plan});

  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncOccurrences = ref.watch(upcomingOccurrencesProvider(plan.id));
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Upcoming'),
          const SizedBox(height: LifeSpace.s8),
          asyncOccurrences.when(
            loading: () => const LLoadingShimmer(height: 40),
            error: (error, stack) => const SizedBox.shrink(),
            data: (occurrences) {
              if (occurrences.isEmpty) {
                return Text(
                  'Nothing scheduled yet.',
                  style: context.textStyles.body.copyWith(
                    color: colors.neutrals.ink2,
                  ),
                );
              }
              return Column(
                children: [
                  for (final occurrence in occurrences)
                    InkWell(
                      onTap: () => OccurrenceSheet.show(
                        context,
                        occurrence: occurrence,
                        plan: plan,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: LifeSpace.s4,
                        ),
                        child: Row(
                          children: [
                            LCheckCircle(
                              checked: occurrence.isCompleted,
                              semanticLabel: _formatDate(
                                occurrence.scheduledDate,
                              ),
                              onChanged: (checked) {
                                final repository = ref.read(
                                  planRepositoryProvider,
                                );
                                if (checked) {
                                  repository.completeOccurrence(
                                    occurrence,
                                    plan,
                                  );
                                } else {
                                  repository.uncompleteOccurrence(occurrence);
                                }
                              },
                            ),
                            Text(
                              _formatDate(occurrence.scheduledDate),
                              style: context.textStyles.body.copyWith(
                                color: colors.neutrals.ink,
                              ),
                            ),
                            if (occurrence.originalDate != null) ...[
                              const SizedBox(width: LifeSpace.s8),
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 14,
                                color: colors.neutrals.ink3,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends ConsumerWidget {
  const _HistorySection({
    required this.plan,
    required this.limit,
    required this.onLoadMore,
  });

  final AppPlan plan;
  final int limit;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncOccurrences = ref.watch(
      historyOccurrencesProvider(plan.id, limit: limit),
    );
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'History'),
          const SizedBox(height: LifeSpace.s8),
          asyncOccurrences.when(
            loading: () => const LLoadingShimmer(height: 40),
            error: (error, stack) => const SizedBox.shrink(),
            data: (occurrences) {
              if (occurrences.isEmpty) {
                return Text(
                  'Nothing yet.',
                  style: context.textStyles.body.copyWith(
                    color: colors.neutrals.ink2,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final occurrence in occurrences)
                    InkWell(
                      onTap: () => OccurrenceSheet.show(
                        context,
                        occurrence: occurrence,
                        plan: plan,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: LifeSpace.s4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              occurrenceStatusIcon(occurrence.status),
                              size: 18,
                              color: occurrenceStatusColor(
                                context,
                                occurrence.status,
                              ),
                            ),
                            const SizedBox(width: LifeSpace.s8),
                            Text(
                              _formatDate(occurrence.scheduledDate),
                              style: context.textStyles.body.copyWith(
                                color: colors.neutrals.ink,
                              ),
                            ),
                            const SizedBox(width: LifeSpace.s8),
                            Text(
                              occurrenceStatusLabel(occurrence.status),
                              style: context.textStyles.caption.copyWith(
                                color: colors.neutrals.ink2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (occurrences.length >= limit)
                    TextButton(
                      onPressed: onLoadMore,
                      child: const Text('Load more'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
