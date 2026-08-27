import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_progress_ring.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/goal_projection.dart';
import 'package:life_os/features/tasks/application/goal_providers.dart';
import 'package:life_os/features/tasks/presentation/goal_colour.dart';
import 'package:life_os/routing/routes.dart';

/// §12.3: a large progress ring, an honest projection (not encouragement —
/// §12.3's own wording), a contributions timeline, linked plans, and
/// milestones. Automatic progress (§12.4) is wired only for the
/// Plan-completion row this pass; see DECISIONS.md.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({required this.goalId, super.key});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncGoal = ref.watch(goalByIdProvider(goalId));
    return asyncGoal.when(
      loading: () => const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const LErrorState(message: "Couldn't load this goal.")),
      data: (goal) {
        if (goal == null) {
          return Scaffold(appBar: AppBar(), body: const LErrorState(message: 'This goal no longer exists.'));
        }
        return Scaffold(
          backgroundColor: colors.neutrals.bg,
          appBar: AppBar(
            title: Text(goal.title),
            actions: [
              IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _editGoal(context, ref, goal)),
              IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: () => _deleteGoal(context, ref, goal)),
            ],
          ),
          body: _GoalDetailBody(goal: goal),
        );
      },
    );
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref, AppGoal goal) async {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(text: goal.targetValue == null ? '' : goal.targetValue!.toString());
    var endDate = goal.endDate == null ? null : DateTime(goal.endDate!.year, goal.endDate!.month, goal.endDate!.day);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Edit goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LTextField(controller: titleController, label: 'Title', outlined: true),
                if (goal.targetValue != null) ...[
                  const SizedBox(height: LifeSpace.s12),
                  LTextField(controller: targetController, label: 'Target', outlined: true, keyboardType: TextInputType.number),
                ],
                const SizedBox(height: LifeSpace.s12),
                LDatePicker(date: endDate, onChanged: (d) => setState(() => endDate = d)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final title = titleController.text.trim();
    if (title.isEmpty) return;
    final target = goal.targetValue == null ? null : double.tryParse(targetController.text.trim());
    await ref
        .read(goalRepositoryProvider)
        .updateGoal(
          goal.copyWith(
            title: title,
            targetValue: target,
            endDate: endDate == null ? null : CivilDate.fromDateTime(endDate!),
            clearEndDate: endDate == null,
          ),
        );
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref, AppGoal goal) async {
    final confirmed = await LConfirmDialog.show(
      context,
      title: 'Delete this goal?',
      message: 'Contributions already logged against linked plans are kept; only the goal itself is removed.',
    );
    if (!confirmed) return;
    await ref.read(goalRepositoryProvider).deleteGoal(goal.id);
    if (context.mounted) context.pop();
  }
}

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal});

  final AppGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colour = resolveGoalColour(context, goal.colour);
    final today = CivilDate.fromDateTime(DateTime.now());
    final projection = computeGoalProjection(goal, today: today);

    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      children: [
        Center(
          child: LProgressRing(
            value: goal.progress ?? (goal.isReached ? 1 : 0),
            size: 120,
            strokeWidth: 10,
            semanticLabel: 'Progress',
            child: Text(
              goal.targetValue == null ? _formatNum(goal.currentValue) : '${_formatNum(goal.currentValue)} / ${_formatNum(goal.targetValue!)}',
              style: context.textStyles.title3.copyWith(color: colour.base),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: LifeSpace.s16),
        Text(
          projection.summary,
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: projection.onTrack == false ? colors.semantic('warning').base : colors.neutrals.ink2,
          ),
        ),
        if (goal.description != null && goal.description!.isNotEmpty) ...[
          const SizedBox(height: LifeSpace.s12),
          Text(goal.description!, style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ],
        const SizedBox(height: LifeSpace.cardGap),
        LButton(label: 'Log progress', variant: LButtonVariant.tonal, onPressed: () => _logProgress(context, ref)),
        const SizedBox(height: LifeSpace.cardGap),
        const LSectionHeader(title: 'Linked plans'),
        const SizedBox(height: LifeSpace.s8),
        Consumer(
          builder: (context, ref, _) {
            final asyncPlans = ref.watch(plansForGoalProvider(goal.id));
            return asyncPlans.when(
              loading: () => const LLoadingShimmer(height: 40),
              error: (error, stack) => const SizedBox.shrink(),
              data: (plans) => plans.isEmpty
                  ? Text('No plans linked yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2))
                  : Column(children: [for (final plan in plans) _PlanRow(plan: plan)]),
            );
          },
        ),
        const SizedBox(height: LifeSpace.cardGap),
        const LSectionHeader(title: 'Milestones'),
        const SizedBox(height: LifeSpace.s8),
        _MilestonesSection(goalId: goal.id),
        const SizedBox(height: LifeSpace.cardGap),
        const LSectionHeader(title: 'Contributions'),
        const SizedBox(height: LifeSpace.s8),
        Consumer(
          builder: (context, ref, _) {
            final asyncContributions = ref.watch(goalContributionsProvider(goal.id));
            return asyncContributions.when(
              loading: () => const LLoadingShimmer(height: 40),
              error: (error, stack) => const SizedBox.shrink(),
              data: (contributions) => contributions.isEmpty
                  ? Text('Nothing logged yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2))
                  : Column(
                      children: [
                        for (final contribution in contributions.take(20))
                          LListTile(title: '+${_formatNum(contribution.value)}', subtitle: contribution.date.toIso()),
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _logProgress(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: '1');
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log progress'),
        content: LTextField(controller: controller, label: 'Amount', outlined: true, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(double.tryParse(controller.text.trim())), child: const Text('Log')),
        ],
      ),
    );
    if (value == null) return;
    await ref.read(goalRepositoryProvider).addManualLog(goal.id, value, CivilDate.fromDateTime(DateTime.now()));
  }

  String _formatNum(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.plan});

  final AppPlan plan;

  @override
  Widget build(BuildContext context) {
    return LListTile(title: plan.title, onTap: () => context.push(Routes.planDetail.replaceFirst(':id', plan.id)));
  }
}

class _MilestonesSection extends ConsumerWidget {
  const _MilestonesSection({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncMilestones = ref.watch(goalMilestonesProvider(goalId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        asyncMilestones.when(
          loading: () => const LLoadingShimmer(height: 40),
          error: (error, stack) => const SizedBox.shrink(),
          data: (milestones) {
            if (milestones.isEmpty) {
              return Text('No milestones yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2));
            }
            return Column(
              children: [
                for (final milestone in milestones)
                  LListTile(
                    leading: Checkbox(
                      value: milestone.isCompleted,
                      onChanged: (checked) => ref.read(goalRepositoryProvider).setMilestoneCompleted(milestone, completed: checked ?? false),
                    ),
                    title: milestone.title ?? 'Milestone',
                    onTap: () => ref
                        .read(goalRepositoryProvider)
                        .setMilestoneCompleted(milestone, completed: !milestone.isCompleted),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: LifeSpace.s8),
        LButton(label: 'Add milestone', variant: LButtonVariant.plain, onPressed: () => _addMilestone(context, ref)),
      ],
    );
  }

  Future<void> _addMilestone(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New milestone'),
        content: LTextField(controller: controller, label: 'Title', outlined: true, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    await ref.read(goalRepositoryProvider).saveMilestone(goalId: goalId, title: title);
  }
}
