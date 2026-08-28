import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';

/// §11: status transitions for a project — active/on hold/done/archived —
/// reachable from the detail screen's "⋯" button (`ProjectRepository.setStatus`
/// otherwise had no caller anywhere in the UI).
Future<void> showProjectActionsMenu({
  required BuildContext context,
  required WidgetRef ref,
  required AppProject project,
  required Offset position,
}) async {
  final repository = ref.read(projectsRepositoryProvider);
  await LMenu.showAt(
    context: context,
    position: position,
    items: [
      if (project.status != ProjectStatus.active)
        LMenuItem(
          label: 'Reactivate',
          icon: Icons.play_arrow_outlined,
          onTap: () => repository.setStatus(project.id, ProjectStatus.active),
        ),
      if (project.status == ProjectStatus.active)
        LMenuItem(
          label: 'Put on hold',
          icon: Icons.pause_outlined,
          onTap: () => repository.setStatus(project.id, ProjectStatus.onHold),
        ),
      if (project.status != ProjectStatus.done)
        LMenuItem(
          label: 'Mark done',
          icon: Icons.check_circle_outline,
          onTap: () => repository.setStatus(project.id, ProjectStatus.done),
        ),
      if (project.status == ProjectStatus.archived)
        LMenuItem(
          label: 'Unarchive',
          icon: Icons.unarchive_outlined,
          onTap: () => repository.setStatus(project.id, ProjectStatus.active),
        )
      else
        LMenuItem(
          label: 'Archive',
          icon: Icons.archive_outlined,
          onTap: () => repository.setStatus(project.id, ProjectStatus.archived),
        ),
    ],
  );
}
