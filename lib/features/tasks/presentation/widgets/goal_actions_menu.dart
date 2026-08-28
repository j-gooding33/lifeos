import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/features/tasks/application/goal_providers.dart';

/// §12: status transitions for a goal — active/ended/archived — reachable
/// from the detail screen's "⋯" button (`GoalRepository.setStatus`
/// otherwise had no caller anywhere in the UI).
Future<void> showGoalActionsMenu({
  required BuildContext context,
  required WidgetRef ref,
  required AppGoal goal,
  required Offset position,
}) async {
  final repository = ref.read(goalRepositoryProvider);
  await LMenu.showAt(
    context: context,
    position: position,
    items: [
      if (goal.status != GoalStatus.active)
        LMenuItem(
          label: 'Reactivate',
          icon: Icons.play_arrow_outlined,
          onTap: () => repository.setStatus(goal.id, GoalStatus.active),
        ),
      if (goal.status == GoalStatus.active)
        LMenuItem(
          label: 'Mark as ended',
          icon: Icons.flag_outlined,
          onTap: () => repository.setStatus(goal.id, GoalStatus.ended),
        ),
      if (goal.status == GoalStatus.archived)
        LMenuItem(
          label: 'Unarchive',
          icon: Icons.unarchive_outlined,
          onTap: () => repository.setStatus(goal.id, GoalStatus.active),
        )
      else
        LMenuItem(
          label: 'Archive',
          icon: Icons.archive_outlined,
          onTap: () => repository.setStatus(goal.id, GoalStatus.archived),
        ),
    ],
  );
}
