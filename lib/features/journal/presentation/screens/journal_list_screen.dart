import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/features/journal/application/journal_providers.dart';
import 'package:life_os/routing/routes.dart';

const _moodEmoji = {1: '😞', 2: '🙁', 3: '😐', 4: '🙂', 5: '😄'};
const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// §22.1: one entry per day, editable any day. Never a streak, never a nag
/// (§22.1's own wording) — this list is a plain chronological log, no
/// "keep your streak alive" framing anywhere.
class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncEntries = ref.watch(recentJournalEntriesProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Jump to a date',
            onPressed: () => _jumpToDate(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: "Today's entry",
            onPressed: () => _openToday(context, ref),
          ),
        ],
      ),
      body: asyncEntries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your journal.", onRetry: () => ref.invalidate(recentJournalEntriesProvider)),
        data: (entries) {
          if (entries.isEmpty) {
            return LEmptyState(
              icon: Icons.book_outlined,
              title: 'No entries yet',
              message: 'A private daily log — what you did, watched, or spent, plus your own words.',
              actionLabel: "Write today's entry",
              onAction: () => _openToday(context, ref),
            );
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final preview = entry.plainText;
              return LListTile(
                leading: entry.mood == null ? null : Text(_moodEmoji[entry.mood] ?? '', style: const TextStyle(fontSize: 22)),
                title: _formatDate(entry.date),
                subtitle: preview.isEmpty ? null : preview.split('\n').first,
                onTap: () => context.push(Routes.journalDate.replaceFirst(':date', entry.date.toIso())),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(CivilDate date) {
    final today = CivilDate.fromDateTime(DateTime.now());
    if (date == today) return 'Today';
    if (date == today.addDays(-1)) return 'Yesterday';
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _openToday(BuildContext context, WidgetRef ref) async {
    final today = CivilDate.fromDateTime(DateTime.now());
    await _openDate(context, ref, today);
  }

  Future<void> _jumpToDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !context.mounted) return;
    await _openDate(context, ref, CivilDate.fromDateTime(picked));
  }

  Future<void> _openDate(BuildContext context, WidgetRef ref, CivilDate date) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref.read(journalRepositoryProvider).getOrCreate(userId: userId, date: date);
    if (!context.mounted) return;
    result.when(
      ok: (entry) => unawaited(context.push(Routes.journalDate.replaceFirst(':date', entry.date.toIso()))),
      err: (_) {},
    );
  }
}
