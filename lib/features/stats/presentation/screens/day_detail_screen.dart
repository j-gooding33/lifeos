import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/day_detail.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/stats/application/stats_providers.dart';

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// §21.2. Serves both `/home/day/:date` and a tapped cell on Your Year —
/// "so it is built once" (the spec's own words). Read-only: this is a
/// summary, not an editor — tapping through to edit a task/occurrence
/// happens from the screen that already owns that action, not from here.
class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({required this.date, super.key});

  final CivilDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncDetail = ref.watch(dayDetailProvider(date));

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: Text('${date.day} ${_monthNames[date.month - 1]} ${date.year}')),
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text("Couldn't load this day.", style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
        ),
        data: (detail) {
          if (detail.isEmpty) {
            return const LEmptyState(icon: Icons.calendar_today_outlined, title: 'Nothing recorded', message: 'Nothing happened on this day.');
          }
          return ListView(
            padding: const EdgeInsets.all(LifeSpace.s16),
            children: [
              _SummaryGrid(detail: detail),
              if (detail.occurrences.isNotEmpty) ...[
                const SizedBox(height: LifeSpace.cardGap),
                const LSectionHeader(title: 'Timeline'),
                const SizedBox(height: LifeSpace.s8),
                for (final occurrence in detail.occurrences) _TimelineRow(occurrence: occurrence),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.detail});

  final DayDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <(String, String)>[
      if (detail.tasks.isNotEmpty) ('Tasks', '${detail.tasksCompleted} / ${detail.tasks.length}'),
      if (detail.occurrences.isNotEmpty)
        ('Plans', '${detail.occurrences.where((o) => o.status == 'completed').length} / ${detail.occurrences.length}'),
      for (final film in detail.filmsWatched) ('Films', film),
      for (final book in detail.booksFinished) ('Books', book),
      if (detail.goalsProgressed > 0) ('Goals', '${detail.goalsProgressed} progressed'),
      if (detail.journalWritten) ('Journal', 'written'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
            child: Row(
              children: [
                SizedBox(width: 72, child: Text(label, style: context.textStyles.mono.copyWith(color: colors.neutrals.ink2))),
                Expanded(child: Text(value, style: context.textStyles.body.copyWith(color: colors.neutrals.ink))),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.occurrence});

  final DayDetailOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final completed = occurrence.status == 'completed';
    final skipped = occurrence.status == 'skipped';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(occurrence.scheduledTime ?? '—', style: context.textStyles.mono.copyWith(color: colors.neutrals.ink3)),
          ),
          const SizedBox(width: LifeSpace.s8),
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: completed ? colors.semantic('success').base : colors.neutrals.ink3,
          ),
          const SizedBox(width: LifeSpace.s8),
          Expanded(
            child: Text(
              occurrence.title,
              style: context.textStyles.body.copyWith(
                color: skipped ? colors.neutrals.ink3 : colors.neutrals.ink,
                decoration: skipped ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
