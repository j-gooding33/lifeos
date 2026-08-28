import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/note_dao.dart';
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/note_repository.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/routing/routes.dart';

/// §17.2: "Every one of those detail screens gets a Notes section." Lives
/// in `design/components` (not inside the Library feature) because every
/// feature's detail screen needs it and CLAUDE.md rule 4 forbids a feature
/// importing another feature's presentation code — this constructs its own
/// [NoteRepository] straight from the DAO, same as `resolveDomainColour`'s
/// cross-feature pattern.
final _notesRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(NoteDao(ref.watch(appDatabaseProvider)));
});

final _linkedNotesProvider = StreamProvider.family<List<AppNote>, (String, String)>((ref, args) {
  return ref.watch(_notesRepositoryProvider).watchLinkedTo(args.$1, args.$2);
});

class LNotesSection extends ConsumerWidget {
  const LNotesSection({required this.entityType, required this.entityId, super.key});

  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncNotes = ref.watch(_linkedNotesProvider((entityType, entityId)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LSectionHeader(
          title: 'Linked notes',
          trailing: IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Add note',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showPicker(context, ref),
          ),
        ),
        const SizedBox(height: LifeSpace.s8),
        asyncNotes.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
          data: (notes) {
            if (notes.isEmpty) {
              return Text('No notes linked yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2));
            }
            return Column(
              children: [
                for (final note in notes)
                  LListTile(
                    leading: const Icon(Icons.note_outlined),
                    title: (note.title?.isNotEmpty ?? false) ? note.title! : 'Untitled',
                    subtitle: note.plainText.isEmpty ? null : note.plainText.split('\n').first,
                    trailing: IconButton(
                      icon: const Icon(Icons.link_off, size: 18),
                      tooltip: 'Unlink',
                      onPressed: () => ref.read(_notesRepositoryProvider).unlinkNote(noteId: note.id, entityType: entityType, entityId: entityId),
                    ),
                    onTap: () => context.push(Routes.libraryNoteDetail.replaceFirst(':id', note.id)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(_notesRepositoryProvider);
    final userId = await ref.read(currentUserIdProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _NotePickerSheet(
        repository: repository,
        userId: userId,
        entityType: entityType,
        entityId: entityId,
      ),
    );
  }
}

class _NotePickerSheet extends StatelessWidget {
  const _NotePickerSheet({
    required this.repository,
    required this.userId,
    required this.entityType,
    required this.entityId,
  });

  final NoteRepository repository;
  final String userId;
  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(LifeSpace.s16, LifeSpace.s16, LifeSpace.s16, LifeSpace.s8),
              child: Text('Link a note', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s8),
              child: TextButton.icon(
                onPressed: () => unawaited(_createAndLink(context)),
                icon: const Icon(Icons.add),
                label: const Text('New note'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<AppNote>>(
                stream: repository.watchAll(userId),
                builder: (context, snapshot) {
                  final notes = snapshot.data ?? const <AppNote>[];
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(LifeSpace.s16),
                      child: Text('No notes yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
                    );
                  }
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return LListTile(
                        leading: const Icon(Icons.note_outlined),
                        title: (note.title?.isNotEmpty ?? false) ? note.title! : 'Untitled',
                        onTap: () async {
                          await repository.linkNote(noteId: note.id, entityType: entityType, entityId: entityId);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAndLink(BuildContext context) async {
    final result = await repository.createNote(userId: userId);
    if (!context.mounted) return;
    await result.when(
      ok: (note) async {
        await repository.linkNote(noteId: note.id, entityType: entityType, entityId: entityId);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        unawaited(context.push(Routes.libraryNoteDetail.replaceFirst(':id', note.id)));
      },
      err: (_) {},
    );
  }
}
