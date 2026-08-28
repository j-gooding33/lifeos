import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_notes_section.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';

/// One screen for both creating a task (`taskId == null`) and viewing an
/// existing one — §10's fields are simple enough that splitting create
/// and detail into separate screens would just duplicate the form.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({this.taskId, super.key});

  final String? taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;
  bool _loaded = false;
  AppTask? _existing;

  bool get _isNew => widget.taskId == null;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = await ref.read(currentUserIdProvider.future);
    final repository = ref.read(taskRepositoryProvider);
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_existing != null) {
      await repository.updateTask(
        _existing!.copyWith(
          title: title,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          dueDate: _dueDate == null ? null : _isoDate(_dueDate!),
          clearDueDate: _dueDate == null,
        ),
      );
    } else {
      await repository.createTask(
        userId: userId,
        title: title,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        dueDate: _dueDate == null ? null : _isoDate(_dueDate!),
      );
    }
    if (mounted) context.pop();
  }

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_isNew) return _buildForm(context);

    final asyncTask = ref.watch(taskByIdProvider(widget.taskId!));
    return asyncTask.when(
      loading: () => const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: const LErrorState(message: "Couldn't load this task."),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const LErrorState(message: 'This task no longer exists.'),
          );
        }
        if (!_loaded) {
          _existing = task;
          _titleController.text = task.title;
          _notesController.text = task.notes ?? '';
          _dueDate = task.dueDate == null ? null : DateTime.parse(task.dueDate!);
          _loaded = true;
        }
        return _buildForm(context, task: task);
      },
    );
  }

  Widget _buildForm(BuildContext context, {AppTask? task}) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(_isNew ? 'New task' : 'Task'),
        actions: [
          if (task != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: () async {
                final confirmed = await LConfirmDialog.show(
                  context,
                  title: 'Delete this task?',
                  message: 'This cannot be undone.',
                );
                if (confirmed) {
                  await ref.read(taskRepositoryProvider).deleteTask(task.id);
                  if (context.mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s20),
        children: [
          if (task != null)
            Padding(
              padding: const EdgeInsets.only(bottom: LifeSpace.s16),
              child: Row(
                children: [
                  LCheckCircle(
                    checked: task.isCompleted,
                    semanticLabel: task.isCompleted ? 'Mark not done' : 'Mark done',
                    onChanged: (checked) {
                      final repository = ref.read(taskRepositoryProvider);
                      if (checked) {
                        repository.completeTask(task);
                      } else {
                        repository.uncompleteTask(task);
                      }
                    },
                  ),
                  Text(
                    task.isCompleted ? 'Done' : 'Not done',
                    style: context.textStyles.body.copyWith(color: colors.neutrals.ink2),
                  ),
                ],
              ),
            ),
          LTextField(controller: _titleController, label: 'Title', outlined: true),
          const SizedBox(height: LifeSpace.s12),
          LTextField(controller: _notesController, label: 'Notes', outlined: true),
          const SizedBox(height: LifeSpace.s12),
          LDatePicker(date: _dueDate, onChanged: (date) => setState(() => _dueDate = date)),
          if (task != null) ...[
            const SizedBox(height: LifeSpace.s24),
            const LSectionHeader(title: 'Subtasks'),
            const SizedBox(height: LifeSpace.s8),
            _SubtasksSection(taskId: task.id),
            const SizedBox(height: LifeSpace.s24),
            LNotesSection(entityType: 'task', entityId: task.id),
          ],
          const SizedBox(height: LifeSpace.s24),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _titleController,
            builder: (context, value, _) {
              final canSave = value.text.trim().isNotEmpty;
              return LButton(label: _isNew ? 'Create' : 'Save', onPressed: canSave ? _save : null);
            },
          ),
        ],
      ),
    );
  }
}

class _SubtasksSection extends ConsumerWidget {
  const _SubtasksSection({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncSubtasks = ref.watch(subtasksOfProvider(taskId));
    final repository = ref.read(taskRepositoryProvider);
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        asyncSubtasks.when(
          loading: () => const LLoadingShimmer(height: 40),
          error: (error, stack) => Text(
            "Couldn't load subtasks.",
            style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2),
          ),
          data: (subtasks) => Column(
            children: [
              for (final subtask in subtasks)
                Row(
                  children: [
                    LCheckCircle(
                      checked: subtask.isCompleted,
                      semanticLabel: subtask.title,
                      onChanged: (checked) =>
                          repository.setSubtaskCompleted(subtask, completed: checked),
                    ),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: context.textStyles.body.copyWith(
                          color: colors.neutrals.ink,
                          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: LTextField(controller: controller, placeholder: 'Add a subtask'),
            ),
            const SizedBox(width: LifeSpace.s8),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add subtask',
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  repository.addSubtask(taskId, title);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
