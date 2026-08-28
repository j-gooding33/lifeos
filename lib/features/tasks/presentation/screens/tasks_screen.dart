import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_squiggle_divider.dart';
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
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Goals',
            onPressed: () => context.push(Routes.goals),
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
        return const _TodayTaskList();
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
          itemBuilder: (context, index) => _buildTaskRow(repository, tasks[index]),
        );
      },
    );
  }
}

Widget _buildTaskRow(TaskRepository repository, AppTask task) {
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

/// Today's own segment (§10.3/M9): today's dated tasks first, then — only
/// if there's anything beyond today — a subtle squiggle divider, a "Beyond
/// today" label, undated tasks, then future-dated tasks. Combines three
/// independent streams rather than one query, since "undated first, future
/// second" here is the opposite order `upcomingTasksProvider` uses for the
/// Next tab (see `task_providers.dart`).
class _TodayTaskList extends ConsumerWidget {
  const _TodayTaskList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncToday = ref.watch(todayTasksProvider);
    final asyncUndated = ref.watch(somedayTasksProvider);
    final asyncFuture = ref.watch(futureDatedTasksProvider);
    final repository = ref.read(taskRepositoryProvider);

    if (asyncToday.isLoading || asyncUndated.isLoading || asyncFuture.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: LifeSpace.s16),
        child: Column(
          children: [LLoadingShimmer(height: 56), SizedBox(height: LifeSpace.s8), LLoadingShimmer(height: 56)],
        ),
      );
    }
    if (asyncToday.hasError || asyncUndated.hasError || asyncFuture.hasError) {
      return LErrorState(
        message: "Couldn't load your tasks.",
        onRetry: () {
          ref
            ..invalidate(todayTasksProvider)
            ..invalidate(somedayTasksProvider)
            ..invalidate(futureDatedTasksProvider);
        },
      );
    }

    final today = asyncToday.requireValue;
    final undated = asyncUndated.requireValue;
    final future = asyncFuture.requireValue;
    final hasBeyondToday = undated.isNotEmpty || future.isNotEmpty;

    if (today.isEmpty && !hasBeyondToday) {
      return const LEmptyState(
        icon: Icons.check_circle_outline,
        title: "Today's clear",
        message: 'Add a task with the + button.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
      children: [
        for (final task in today) ...[_buildTaskRow(repository, task), const SizedBox(height: LifeSpace.s4)],
        if (hasBeyondToday) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: LifeSpace.s4),
            child: LSquiggleDivider(),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: LifeSpace.s8),
            child: LSectionHeader(title: 'Beyond today'),
          ),
          for (final task in undated) ...[_buildTaskRow(repository, task), const SizedBox(height: LifeSpace.s4)],
          for (final task in future) ...[_buildTaskRow(repository, task), const SizedBox(height: LifeSpace.s4)],
        ],
      ],
    );
  }
}
