import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/note_dao.dart';
import 'package:life_os/data/repositories/note_repository.dart';
import 'package:life_os/design/components/l_chip.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

class _QuickAddType {
  const _QuickAddType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// §6.2's type picker — the Layer 1/Layer 2 natural-language capture and
/// the "Ask AI" entry point are separate, larger pieces of work (a
/// 120-case parser suite and an AI proxy respectively) sequenced after
/// this; see DECISIONS.md. Every other type here now opens a real
/// destination: "Task", "Event", "Plan", "Habit" and "Goal" open a
/// dedicated creation screen; "Project" opens the Projects list (its own
/// create action is the list's own + button); "Note" creates an empty
/// note and opens it directly, same as the Notes screen's own + button;
/// "Film"/"Book" open their search screen, since adding one starts with
/// finding it; "Expense" opens the expense editor; "Journal" opens
/// today's entry. Only "Reminder" has nothing to open — there's no
/// standalone reminder entity in this app's model (`reminders_table.dart`
/// exists but nothing reads or writes it yet) — so it honestly says so
/// rather than opening something that doesn't exist (CLAUDE.md rule 1).
class QuickAddSheet extends ConsumerWidget {
  const QuickAddSheet({super.key});

  static const _primary = [
    _QuickAddType('Task', Icons.check_circle_outline),
    _QuickAddType('Event', Icons.event_outlined),
    _QuickAddType('Plan', Icons.repeat_outlined),
    _QuickAddType('Habit', Icons.track_changes_outlined),
    _QuickAddType('Goal', Icons.flag_outlined),
    _QuickAddType('Project', Icons.folder_outlined),
  ];

  static const _secondary = ['Note', 'Film', 'Book', 'Expense', 'Journal', 'Reminder'];

  static Future<void> show(BuildContext context) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.4],
      builder: (context) => const QuickAddSheet(),
    );
  }

  void _select(BuildContext context, WidgetRef ref, String type) {
    switch (type) {
      case 'Task':
        Navigator.of(context).maybePop();
        context.push(Routes.tasksNew);
      case 'Event':
        Navigator.of(context).maybePop();
        context.push(Routes.calendarEvent.replaceFirst(':id', 'new'));
      case 'Plan':
        Navigator.of(context).maybePop();
        context.push(Routes.plansNew);
      case 'Habit':
        Navigator.of(context).maybePop();
        context.push(Routes.habitsNew);
      case 'Project':
        Navigator.of(context).maybePop();
        context.push(Routes.projects);
      case 'Goal':
        Navigator.of(context).maybePop();
        context.push(Routes.goalsNew);
      case 'Film':
        Navigator.of(context).maybePop();
        context.push(Routes.libraryFilmsSearch);
      case 'Book':
        Navigator.of(context).maybePop();
        context.push(Routes.libraryBooksSearch);
      case 'Expense':
        Navigator.of(context).maybePop();
        context.push(Routes.financeExpense.replaceFirst(':id', 'new'));
      case 'Journal':
        Navigator.of(context).maybePop();
        context.push(Routes.journalDate.replaceFirst(':date', CivilDate.fromDateTime(DateTime.now()).toIso()));
      case 'Note':
        // Needs the repository call to finish before there's an id to
        // navigate to, so it can't just pop-then-push like the rest.
        unawaited(_createNote(context, ref));
      default:
        LToast.show(context, "$type creation is on the roadmap but hasn't shipped.");
    }
  }

  /// Same as the Notes screen's own + button: creates an empty note and
  /// opens it directly rather than asking for a title upfront.
  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final repository = NoteRepository(NoteDao(ref.read(appDatabaseProvider)));
    final result = await repository.createNote(userId: userId);
    if (!context.mounted) return;
    Navigator.of(context).maybePop();
    result.when(
      ok: (note) => context.push(Routes.libraryNoteDetail.replaceFirst(':id', note.id)),
      err: (_) => LToast.show(context, "Couldn't create a new note."),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you adding?',
            style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
          ),
          const SizedBox(height: LifeSpace.s16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: LifeSpace.s12,
            crossAxisSpacing: LifeSpace.s12,
            childAspectRatio: 2.4,
            children: [
              for (final type in _primary)
                _PrimaryTile(type: type, onTap: () => _select(context, ref, type.label)),
            ],
          ),
          const SizedBox(height: LifeSpace.s16),
          Wrap(
            spacing: LifeSpace.s8,
            runSpacing: LifeSpace.s8,
            children: [
              for (final label in _secondary)
                LChip(label: label, onTap: () => _select(context, ref, label)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryTile extends StatelessWidget {
  const _PrimaryTile({required this.type, required this.onTap});

  final _QuickAddType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.neutrals.surfaceAlt,
      borderRadius: BorderRadius.circular(LifeRadius.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(LifeRadius.control),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
          child: Row(
            children: [
              Icon(type.icon, color: colors.accent.base),
              const SizedBox(width: LifeSpace.s12),
              Text(type.label, style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
