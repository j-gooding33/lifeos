import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/rule_description.dart';
import 'package:life_os/routing/routes.dart';

const _dayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// §13.2. A row per habit with a 7-day dot strip — tap any dot to complete
/// retroactively, per that section's own wording. Habits are Plans
/// (`kind = 'habit'`, §7.1), so this reuses `PlanRepository` end to end;
/// nothing habit-specific exists at the data layer.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncHabits = ref.watch(habitPlansProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Habits')),
      body: asyncHabits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your habits.", onRetry: () => ref.invalidate(habitPlansProvider)),
        data: (habits) {
          if (habits.isEmpty) {
            return const LEmptyState(
              icon: Icons.track_changes_outlined,
              title: 'No habits yet',
              message: 'Add one with the + button — a name, an icon, and how often.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(LifeSpace.s16),
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s12),
            itemBuilder: (context, index) => _HabitRow(plan: habits[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.habitsNew),
        tooltip: 'New habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.plan});

  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final planColour = resolvePlanColour(context, plan.colour);
    final today = CivilDate.fromDateTime(DateTime.now());
    final weekStart = today.addDays(-6);
    final asyncWeek = ref.watch(planOccurrencesInRangeProvider(plan.id, weekStart, today));
    final repository = ref.read(planRepositoryProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push(Routes.habitDetail.replaceFirst(':id', plan.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: planColour.soft, child: Icon(planIconFor(plan.icon), color: planColour.base, size: 18)),
                const SizedBox(width: LifeSpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.title, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
                      Text(describeRule(plan.rule), style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: LifeSpace.s8),
            asyncWeek.when(
              loading: () => const SizedBox(height: 44),
              error: (error, stack) => const SizedBox.shrink(),
              data: (occurrences) {
                final byDate = {for (final o in occurrences) o.scheduledDate: o};
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 6; i >= 0; i--) _dayDot(context, repository, weekStart.addDays(6 - i), byDate),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayDot(BuildContext context, PlanRepository repository, CivilDate date, Map<CivilDate, AppOccurrence> byDate) {
    final colors = context.colors;
    final occurrence = byDate[date];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_dayInitials[date.isoWeekday - 1], style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
        if (occurrence == null)
          const SizedBox(width: 44, height: 44)
        else
          LCheckCircle(
            checked: occurrence.isCompleted,
            semanticLabel: '${date.day}',
            onChanged: (checked) {
              if (checked) {
                repository.completeOccurrence(occurrence, plan);
              } else {
                repository.uncompleteOccurrence(occurrence);
              }
            },
          ),
      ],
    );
  }
}
