import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/features/library/application/note_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §17.1. "Rich enough to be useful, not a Notion clone" — a flat list,
/// pinned first, title + a one-line preview from the plain-text
/// projection. Tapping "+" creates an empty note and opens it directly,
/// same as most note apps, rather than asking for a title upfront.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncNotes = ref.watch(allNotesProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'New note', onPressed: () => _createNote(context, ref))],
      ),
      body: asyncNotes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your notes.", onRetry: () => ref.invalidate(allNotesProvider)),
        data: (notes) {
          if (notes.isEmpty) {
            return const LEmptyState(icon: Icons.note_outlined, title: 'No notes yet', message: 'Add one with the + button.');
          }
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              final preview = note.plainText;
              return LListTile(
                leading: note.pinned ? const Icon(Icons.push_pin_outlined) : null,
                title: (note.title?.isNotEmpty ?? false) ? note.title! : 'Untitled',
                subtitle: preview.isEmpty ? null : preview.split('\n').first,
                onTap: () => context.push(Routes.libraryNoteDetail.replaceFirst(':id', note.id)),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref.read(noteRepositoryProvider).createNote(userId: userId);
    if (!context.mounted) return;
    result.when(
      ok: (note) => unawaited(context.push(Routes.libraryNoteDetail.replaceFirst(':id', note.id))),
      err: (_) {},
    );
  }
}
