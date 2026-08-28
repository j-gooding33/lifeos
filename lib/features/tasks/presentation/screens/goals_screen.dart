import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_progress_ring.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/goal_providers.dart';
import 'package:life_os/features/tasks/presentation/goal_colour.dart';
import 'package:life_os/routing/routes.dart';

const _typeIcons = {
  GoalType.count: Icons.tag_outlined,
  GoalType.quantity: Icons.straighten_outlined,
  GoalType.duration: Icons.schedule_outlined,
  GoalType.currency: Icons.savings_outlined,
  GoalType.milestone: Icons.checklist_outlined,
  GoalType.boolean: Icons.flag_outlined,
};

/// §12. "The layer that gives Plans and Tasks a reason." Progress here is
/// `AppGoal.currentValue`, a cached total kept in sync by
/// `GoalRepository.addContribution`/`reverseContribution` — never derived
/// at render time the way Project progress is (§12.4 requires an
/// auditable contribution row for every change).
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncGoals = ref.watch(allGoalsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'New goal', onPressed: () => context.push(Routes.goalsNew)),
        ],
      ),
      body: asyncGoals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your goals.", onRetry: () => ref.invalidate(allGoalsProvider)),
        data: (goals) {
          final active = goals.where((g) => g.status != GoalStatus.archived).toList();
          if (active.isEmpty) {
            return const LEmptyState(
              icon: Icons.flag_outlined,
              title: 'No goals yet',
              message: 'Add one with the + button — a measurable outcome over a period.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
            itemCount: active.length,
            separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
            itemBuilder: (context, index) => _GoalRow(goal: active[index]),
          );
        },
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal});

  final AppGoal goal;

  @override
  Widget build(BuildContext context) {
    final colour = resolveGoalColour(context, goal.colour);
    final progress = goal.progress;
    return LListTile(
      leading: LProgressRing(
        value: progress ?? (goal.isReached ? 1 : 0),
        size: 36,
        strokeWidth: 3,
        semanticLabel: '${goal.title} progress',
        child: Icon(_typeIcons[goal.type], size: 16, color: colour.base),
      ),
      title: goal.title,
      subtitle: goal.targetValue == null
          ? null
          : '${_formatNum(goal.currentValue)} / ${_formatNum(goal.targetValue!)}${goal.unit == null ? '' : ' ${goal.unit}'}',
      trailing: goal.status == GoalStatus.ended ? const Icon(Icons.flag_outlined) : null,
      onTap: () => context.push(Routes.goalDetail.replaceFirst(':id', goal.id)),
    );
  }

  String _formatNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}
