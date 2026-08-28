import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:life_os/design/components/l_block_editor.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/note_providers.dart';

/// §17.1's note editor. A custom editor, not `flutter_quill` — see
/// DECISIONS.md. The block-list itself is `LBlockEditor`, shared with the
/// Journal entry screen (§22.1 uses the same `blocksJson` shape).
class NoteEditorScreen extends ConsumerWidget {
  const NoteEditorScreen({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncNote = ref.watch(noteByIdProvider(noteId));
    return asyncNote.when(
      loading: () => const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const LErrorState(message: "Couldn't load this note.")),
      data: (note) {
        if (note == null) {
          return Scaffold(backgroundColor: colors.neutrals.bg, appBar: AppBar(), body: const LErrorState(message: 'This note no longer exists.'));
        }
        return _NoteEditorBody(key: ValueKey(note.id), note: note);
      },
    );
  }
}

class _NoteEditorBody extends ConsumerStatefulWidget {
  const _NoteEditorBody({required this.note, super.key});

  final AppNote note;

  @override
  ConsumerState<_NoteEditorBody> createState() => _NoteEditorBodyState();
}

class _NoteEditorBodyState extends ConsumerState<_NoteEditorBody> {
  late final _titleController = TextEditingController(text: widget.note.title ?? '');
  late List<NoteBlock> _blocks = List.of(widget.note.blocks);
  var _dirty = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    await ref
        .read(noteRepositoryProvider)
        .updateNote(widget.note.copyWith(title: title.isEmpty ? null : title, clearTitle: title.isEmpty, blocks: _blocks));
    setState(() => _dirty = false);
  }

  Future<void> _delete() async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this note?', message: 'This cannot be undone.');
    if (!confirmed) return;
    await ref.read(noteRepositoryProvider).deleteNote(widget.note.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            tooltip: widget.note.pinned ? 'Unpin' : 'Pin',
            color: widget.note.pinned ? colors.accent.base : null,
            onPressed: () => ref.read(noteRepositoryProvider).setPinned(widget.note.id, pinned: !widget.note.pinned),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: _delete),
          IconButton(icon: const Icon(Icons.check), tooltip: 'Save', onPressed: _dirty ? _save : null),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(LifeSpace.s16),
          children: [
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() => _dirty = true),
              style: context.textStyles.title3.copyWith(color: colors.neutrals.ink),
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
            ),
            const SizedBox(height: LifeSpace.s12),
            LBlockEditor(
              blocks: widget.note.blocks,
              onChanged: (blocks) {
                _blocks = blocks;
                setState(() => _dirty = true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
