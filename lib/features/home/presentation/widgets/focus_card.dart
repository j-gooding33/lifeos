import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/features/home/presentation/widgets/suggestion_card.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:life_os/routing/routes.dart';

/// Always first, cannot be hidden or moved (§5.3). Merges today's events,
/// plan occurrences and tasks — until M6/M7 exist, that merge is just
/// tasks, honestly (see `home_providers.dart`).
class FocusCard extends ConsumerWidget {
  const FocusCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    if (snapshot.hasNothingToday) {
      return const SuggestionCard(title: 'Nothing scheduled today');
    }

    if (snapshot.allDoneToday) {
      return LCard(
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colors.semantic('success').base),
            const SizedBox(width: LifeSpace.s8),
            Text(
              "Today's done. ${snapshot.doneToday} of ${snapshot.totalToday}.",
              style: textStyles.bodyStrong.copyWith(color: colors.neutrals.ink),
            ),
          ],
        ),
      );
    }

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LSectionHeader(
            title: 'Today',
            trailing: Text(
              '${snapshot.doneToday}/${snapshot.totalToday}',
              style: textStyles.mono.copyWith(color: colors.neutrals.ink2),
            ),
          ),
          const SizedBox(height: LifeSpace.s8),
          for (final task in snapshot.focusItems) _FocusRow(task: task),
        ],
      ),
    );
  }
}

class _FocusRow extends ConsumerWidget {
  const _FocusRow({required this.task});

  final AppTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return InkWell(
      onTap: () => context.push(Routes.taskDetail.replaceFirst(':id', task.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
        child: Row(
          children: [
            LCheckCircle(
              checked: task.isCompleted,
              semanticLabel: task.title,
              onChanged: (checked) {
                final repository = ref.read(taskRepositoryProvider);
                if (checked) {
                  repository.completeTask(task);
                } else {
                  repository.uncompleteTask(task);
                }
              },
            ),
            Expanded(
              child: Text(
                task.title,
                style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
