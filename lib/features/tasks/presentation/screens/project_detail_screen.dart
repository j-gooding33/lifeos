import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_files_section.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_notes_section.dart';
import 'package:life_os/design/components/l_progress_ring.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:life_os/features/tasks/presentation/project_colour.dart';
import 'package:life_os/features/tasks/presentation/screens/projects_screen.dart';
import 'package:life_os/features/tasks/presentation/widgets/project_actions_menu.dart';
import 'package:life_os/features/tasks/presentation/widgets/task_row.dart';

const _colourOptions = ['tasks', 'plans', 'habits', 'goals', 'study'];

/// §11.3: header with title, colour, deadline chip, and a progress ring;
/// Tasks grouped To do / Done with inline add; Notes as free text. Files
/// and a filtered Activity history are deferred — see DECISIONS.md.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncProject = ref.watch(projectByIdProvider(projectId));
    return asyncProject.when(
      loading: () => const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const LErrorState(message: "Couldn't load this project.")),
      data: (project) {
        if (project == null) {
          return Scaffold(appBar: AppBar(), body: const LErrorState(message: 'This project no longer exists.'));
        }
        return Scaffold(
          backgroundColor: colors.neutrals.bg,
          appBar: AppBar(
            title: Text(project.title),
            actions: [
              IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _editProject(context, ref, project)),
              Builder(
                builder: (buttonContext) => IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Project actions',
                  onPressed: () {
                    final box = buttonContext.findRenderObject()! as RenderBox;
                    final position = box.localToGlobal(box.size.center(Offset.zero));
                    showProjectActionsMenu(context: context, ref: ref, project: project, position: position);
                  },
                ),
              ),
              IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: () => _deleteProject(context, ref, project)),
            ],
          ),
          body: _ProjectDetailBody(project: project),
        );
      },
    );
  }

  Future<void> _editProject(BuildContext context, WidgetRef ref, AppProject project) async {
    final titleController = TextEditingController(text: project.title);
    final descriptionController = TextEditingController(text: project.description ?? '');
    var colour = project.colour ?? 'tasks';
    var deadline = project.deadline == null ? null : DateTime(project.deadline!.year, project.deadline!.month, project.deadline!.day);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Edit project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LTextField(controller: titleController, label: 'Title', outlined: true),
                const SizedBox(height: LifeSpace.s12),
                LTextField(controller: descriptionController, label: 'Notes', outlined: true),
                const SizedBox(height: LifeSpace.s12),
                LDatePicker(date: deadline, onChanged: (d) => setState(() => deadline = d)),
                const SizedBox(height: LifeSpace.s12),
                Wrap(
                  spacing: LifeSpace.s8,
                  children: [
                    for (final domain in _colourOptions)
                      GestureDetector(
                        onTap: () => setState(() => colour = domain),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: resolveProjectColour(context, domain).base,
                            shape: BoxShape.circle,
                            border: colour == domain ? Border.all(color: context.colors.neutrals.ink, width: 2) : null,
                          ),
                        ),
                      ),
                  ],
                ),
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
    await ref
        .read(projectsRepositoryProvider)
        .updateProject(
          project.copyWith(
            title: title,
            description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
            colour: colour,
            deadline: deadline == null ? null : CivilDate.fromDateTime(deadline!),
            clearDeadline: deadline == null,
          ),
        );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref, AppProject project) async {
    final tasks = await ref.read(taskRepositoryProvider).watchByProjectId(project.id).first;
    if (!context.mounted) return;

    if (tasks.isEmpty) {
      final confirmed = await LConfirmDialog.show(context, title: 'Delete this project?', message: 'This cannot be undone.');
      if (confirmed) {
        await ref.read(projectsRepositoryProvider).deleteProject(project.id);
        if (context.mounted) context.pop();
      }
      return;
    }

    // §11.4: "Delete N tasks too, or move them to no project?" — never
    // silently orphan or silently destroy.
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this project?'),
        content: Text('Delete ${tasks.length} task${tasks.length == 1 ? '' : 's'} too, or move ${tasks.length == 1 ? 'it' : 'them'} to no project?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('move'), child: const Text('Move to no project')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop('delete'), child: const Text('Delete tasks too')),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    final taskRepository = ref.read(taskRepositoryProvider);
    if (choice == 'delete') {
      await taskRepository.deleteAllForProject(project.id);
    } else {
      await taskRepository.clearProjectForAll(project.id);
    }
    await ref.read(projectsRepositoryProvider).deleteProject(project.id);
    if (context.mounted) context.pop();
  }
}

class _ProjectDetailBody extends ConsumerWidget {
  const _ProjectDetailBody({required this.project});

  final AppProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final colour = resolveProjectColour(context, project.colour);
    final asyncTasks = ref.watch(tasksForProjectProvider(project.id));

    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      children: [
        Row(
          children: [
            asyncTasks.when(
              loading: () => const LProgressRing(value: 0, size: 56),
              error: (error, stack) => const LProgressRing(value: 0, size: 56),
              data: (tasks) {
                final progress = tasks.isEmpty ? 0.0 : tasks.where((t) => t.isCompleted).length / tasks.length;
                return LProgressRing(
                  value: progress,
                  size: 56,
                  strokeWidth: 5,
                  semanticLabel: 'Progress',
                  child: Text('${(progress * 100).round()}%', style: context.textStyles.caption.copyWith(color: colour.base)),
                );
              },
            ),
            const SizedBox(width: LifeSpace.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DeadlineChip(deadline: project.deadline),
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const SizedBox(height: LifeSpace.s8),
                    Text(project.description!, style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: LifeSpace.cardGap),
        const LSectionHeader(title: 'Tasks'),
        const SizedBox(height: LifeSpace.s8),
        _InlineAddTask(projectId: project.id),
        const SizedBox(height: LifeSpace.s8),
        asyncTasks.when(
          loading: () => const LLoadingShimmer(height: 100),
          error: (error, stack) => const SizedBox.shrink(),
          data: (tasks) {
            final todo = tasks.where((t) => !t.isCompleted).toList();
            final done = tasks.where((t) => t.isCompleted).toList();
            if (tasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: LifeSpace.s16),
                child: Text('No tasks yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
              );
            }
            return Column(
              children: [
                for (final task in todo) _taskRow(ref, task),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: LifeSpace.s12),
                  Text('Done', style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
                  for (final task in done) _taskRow(ref, task),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: LifeSpace.cardGap),
        LFilesSection(entityType: 'project', entityId: project.id),
        const SizedBox(height: LifeSpace.cardGap),
        LNotesSection(entityType: 'project', entityId: project.id),
      ],
    );
  }

  Widget _taskRow(WidgetRef ref, AppTask task) {
    final repository = ref.read(taskRepositoryProvider);
    return TaskRow(
      task: task,
      onToggleComplete: (checked) {
        if (checked) {
          repository.completeTask(task);
        } else {
          repository.uncompleteTask(task);
        }
      },
      onDelete: () => repository.deleteTask(task.id),
    );
  }
}

class _InlineAddTask extends ConsumerStatefulWidget {
  const _InlineAddTask({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_InlineAddTask> createState() => _InlineAddTaskState();
}

class _InlineAddTaskState extends ConsumerState<_InlineAddTask> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(taskRepositoryProvider).createTask(userId: userId, title: title, projectId: widget.projectId);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: LTextField(controller: _controller, placeholder: 'Add a task', onChanged: (_) {})),
        const SizedBox(width: LifeSpace.s8),
        LButton(label: 'Add', variant: LButtonVariant.tonal, onPressed: _add),
      ],
    );
  }
}
