import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:life_os/features/tasks/presentation/project_colour.dart';
import 'package:life_os/routing/routes.dart';

/// §11. A container for tasks with a shared outcome, progress and
/// deadline. Progress is always derived from `tasksForProjectProvider`
/// here, never a stored field (§11.2).
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncProjects = ref.watch(allProjectsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Projects')),
      body: asyncProjects.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your projects.", onRetry: () => ref.invalidate(allProjectsProvider)),
        data: (projects) {
          final active = projects.where((p) => !p.isArchived).toList();
          if (active.isEmpty) {
            return const LEmptyState(
              icon: Icons.folder_outlined,
              title: 'No projects yet',
              message: 'Add one with the + button to group tasks toward a shared outcome.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
            itemCount: active.length,
            separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
            itemBuilder: (context, index) => _ProjectRow(project: active[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createProject(context, ref),
        tooltip: 'New project',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New project'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (title == null || title.isEmpty || !context.mounted) return;
    final result = await ref.read(projectsRepositoryProvider).createProject(userId: await _userId(ref), title: title);
    if (!context.mounted) return;
    result.when(
      ok: (project) => unawaited(context.push(Routes.projectDetail.replaceFirst(':id', project.id))),
      err: (_) {},
    );
  }

  Future<String> _userId(WidgetRef ref) async {
    return ref.read(currentUserIdProvider.future);
  }
}

class _ProjectRow extends ConsumerWidget {
  const _ProjectRow({required this.project});

  final AppProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colour = resolveProjectColour(context, project.colour);
    final leading = CircleAvatar(radius: 18, backgroundColor: colour.soft, child: Icon(Icons.folder_outlined, color: colour.base, size: 18));
    final asyncTasks = ref.watch(tasksForProjectProvider(project.id));

    return asyncTasks.when(
      loading: () => LListTile(leading: leading, title: project.title, onTap: () => _open(context)),
      error: (error, stack) => LListTile(leading: leading, title: project.title, onTap: () => _open(context)),
      data: (tasks) {
        final progress = _progressOf(tasks);
        return LListTile(
          leading: leading,
          title: project.title,
          subtitle: progress == null ? 'No tasks yet' : '${(progress * 100).round()}% done',
          trailing: DeadlineChip(deadline: project.deadline),
          onTap: () => _open(context),
        );
      },
    );
  }

  void _open(BuildContext context) => context.push(Routes.projectDetail.replaceFirst(':id', project.id));

  double? _progressOf(List<AppTask> tasks) {
    if (tasks.isEmpty) return null;
    final done = tasks.where((t) => t.isCompleted).length;
    return done / tasks.length;
  }
}

/// §11.3: "turns amber at 3 days, danger when overdue."
class DeadlineChip extends StatelessWidget {
  const DeadlineChip({required this.deadline, super.key});

  final CivilDate? deadline;

  @override
  Widget build(BuildContext context) {
    final deadline = this.deadline;
    if (deadline == null) return const SizedBox.shrink();
    final colors = context.colors;
    final today = CivilDate.fromDateTime(DateTime.now());
    final daysLeft = CivilDate.daysBetween(today, deadline);
    final color = daysLeft < 0
        ? colors.semantic('danger')
        : daysLeft <= 3
        ? colors.semantic('warning')
        : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s8, vertical: LifeSpace.s4),
      decoration: BoxDecoration(
        color: color == null ? colors.neutrals.surfaceAlt : color.base.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(LifeRadius.control),
      ),
      child: Text(
        deadline.toIso(),
        style: context.textStyles.caption.copyWith(color: color?.base ?? colors.neutrals.ink2),
      ),
    );
  }
}
