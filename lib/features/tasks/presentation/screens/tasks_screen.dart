import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:life_os/features/tasks/presentation/widgets/task_row.dart';
import 'package:life_os/routing/routes.dart';

enum _TaskSegment { today, upcoming, overdue, completed }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  var _segment = _TaskSegment.today;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Projects',
            onPressed: () => context.push(Routes.projects),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_TaskSegment>(
              segments: const {
                _TaskSegment.today: 'Today',
                _TaskSegment.upcoming: 'Next',
                _TaskSegment.overdue: 'Overdue',
                _TaskSegment.completed: 'Done',
              },
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(child: _buildSegment()),
        ],
      ),
    );
  }

  Widget _buildSegment() {
    switch (_segment) {
      case _TaskSegment.today:
        final async = ref.watch(todayTasksProvider);
        return _TaskList(
          asyncTasks: async,
          emptyTitle: "Today's clear",
          onRetry: () => ref.invalidate(todayTasksProvider),
        );
      case _TaskSegment.upcoming:
        final async = ref.watch(upcomingTasksProvider);
        return _TaskList(
          asyncTasks: async,
          emptyTitle: 'Nothing upcoming',
          onRetry: () => ref.invalidate(upcomingTasksProvider),
        );
      case _TaskSegment.overdue:
        final async = ref.watch(overdueTasksProvider);
        return _TaskList(
          asyncTasks: async,
          emptyTitle: 'Nothing overdue',
          onRetry: () => ref.invalidate(overdueTasksProvider),
        );
      case _TaskSegment.completed:
        final async = ref.watch(completedTasksProvider);
        return _TaskList(
          asyncTasks: async,
          emptyTitle: 'Nothing completed yet',
          onRetry: () => ref.invalidate(completedTasksProvider),
        );
    }
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.asyncTasks, required this.emptyTitle, required this.onRetry});

  final AsyncValue<List<AppTask>> asyncTasks;
  final String emptyTitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(taskRepositoryProvider);

    return asyncTasks.when(
      loading: () => ListView(
        padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
        children: const [
          LLoadingShimmer(height: 56),
          SizedBox(height: LifeSpace.s8),
          LLoadingShimmer(height: 56),
        ],
      ),
      error: (error, stack) => LErrorState(message: "Couldn't load your tasks.", onRetry: onRetry),
      data: (tasks) {
        if (tasks.isEmpty) {
          return LEmptyState(
            icon: Icons.check_circle_outline,
            title: emptyTitle,
            message: 'Add a task with the + button.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
          itemBuilder: (context, index) {
            final task = tasks[index];
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
          },
        );
      },
    );
  }
}
