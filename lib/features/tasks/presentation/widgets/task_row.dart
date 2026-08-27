import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_swipe_row.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/routing/routes.dart';

/// A single row in any of the four task views (§10.3/§10.4). Complete is a
/// tap on the circle; reschedule/priority/delete are behind a left swipe
/// *and* the long-press menu (§2.9 — every swipe action needs a
/// long-press equivalent, enforced structurally by `LSwipeRow` itself).
class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    super.key,
  });

  final AppTask task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onDelete;

  static const _priorityLabels = {
    TaskPriority.low: 'Low',
    TaskPriority.medium: 'Medium',
    TaskPriority.high: 'High',
  };

  @override
  Widget build(BuildContext context) {
    return LSwipeRow(
      actions: [
        LSwipeAction(
          label: 'Delete',
          icon: Icons.delete_outline,
          onTap: () async {
            final confirmed = await LConfirmDialog.show(
              context,
              title: 'Delete this task?',
              message: 'This cannot be undone.',
            );
            if (confirmed) onDelete();
          },
        ),
      ],
      child: LListTile(
        leading: LCheckCircle(
          checked: task.isCompleted,
          semanticLabel: task.isCompleted ? 'Mark not done' : 'Mark done',
          onChanged: (checked) {
            onToggleComplete(checked);
            if (checked) LToast.show(context, 'Done');
          },
        ),
        title: task.title,
        subtitle: task.dueDate,
        trailing: task.priority == TaskPriority.none
            ? null
            : LChip(label: _priorityLabels[task.priority]!),
        onTap: () => context.push(Routes.taskDetail.replaceFirst(':id', task.id)),
      ),
    );
  }
}
