import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/note_providers.dart';

const _insertableTypes = [
  NoteBlockType.paragraph,
  NoteBlockType.heading,
  NoteBlockType.checklistItem,
  NoteBlockType.bullet,
  NoteBlockType.quote,
  NoteBlockType.code,
  NoteBlockType.divider,
];

const _typeLabels = {
  NoteBlockType.paragraph: 'Text',
  NoteBlockType.heading: 'Heading',
  NoteBlockType.checklistItem: 'Checklist item',
  NoteBlockType.bullet: 'Bullet',
  NoteBlockType.quote: 'Quote',
  NoteBlockType.code: 'Code',
  NoteBlockType.divider: 'Divider',
};

/// §17.1's block editor. A custom editor, not `flutter_quill` — see
/// DECISIONS.md. Append-and-delete only in this pass; no drag-reorder yet.
/// `image`/`linkCard` blocks round-trip through `NoteBlock`'s JSON but
/// can't be inserted from here (no file picker / OG fetch built).
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
  late List<TextEditingController> _blockControllers = [
    for (final block in _blocks) TextEditingController(text: block.text ?? ''),
  ];
  var _dirty = false;

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _blockControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addBlock(NoteBlockType type) {
    setState(() {
      _blocks = [..._blocks, NoteBlock(type: type, text: type == NoteBlockType.divider ? null : '')];
      _blockControllers = [..._blockControllers, TextEditingController()];
      _dirty = true;
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      _blocks = [..._blocks]..removeAt(index);
      _blockControllers.removeAt(index).dispose();
      _dirty = true;
    });
  }

  void _toggleChecked(int index) {
    setState(() {
      _blocks[index] = _blocks[index].copyWith(checked: !_blocks[index].checked);
      _dirty = true;
    });
  }

  static const _textEditableTypes = {
    NoteBlockType.paragraph,
    NoteBlockType.heading,
    NoteBlockType.checklistItem,
    NoteBlockType.bullet,
    NoteBlockType.quote,
    NoteBlockType.code,
  };

  Future<void> _save() async {
    // Divider/image/linkCard blocks have no bound TextField (their
    // controller is always empty) — applying it here would overwrite
    // their real `text: null` with `''`.
    final blocks = [
      for (var i = 0; i < _blocks.length; i++)
        if (_textEditableTypes.contains(_blocks[i].type)) _blocks[i].copyWith(text: _blockControllers[i].text) else _blocks[i],
    ];
    final title = _titleController.text.trim();
    await ref
        .read(noteRepositoryProvider)
        .updateNote(widget.note.copyWith(title: title.isEmpty ? null : title, clearTitle: title.isEmpty, blocks: blocks));
    setState(() => _dirty = false);
  }

  Future<void> _delete() async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this note?', message: 'This cannot be undone.');
    if (!confirmed) return;
    await ref.read(noteRepositoryProvider).deleteNote(widget.note.id);
    if (mounted) context.pop();
  }

  Future<void> _pickBlockType() async {
    final renderBox = context.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(renderBox.size.bottomCenter(Offset.zero));
    await LMenu.showAt(
      context: context,
      position: position,
      items: [for (final type in _insertableTypes) LMenuItem(label: _typeLabels[type]!, onTap: () => _addBlock(type))],
    );
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
        child: Column(
          children: [
            Expanded(
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
                  for (var i = 0; i < _blocks.length; i++)
                    _BlockEditor(
                      block: _blocks[i],
                      controller: _blockControllers[i],
                      onChanged: () => setState(() => _dirty = true),
                      onToggleChecked: () => _toggleChecked(i),
                      onDelete: () => _deleteBlock(i),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(LifeSpace.s12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(onPressed: _pickBlockType, icon: const Icon(Icons.add), label: const Text('Add block')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockEditor extends StatelessWidget {
  const _BlockEditor({
    required this.block,
    required this.controller,
    required this.onChanged,
    required this.onToggleChecked,
    required this.onDelete,
  });

  final NoteBlock block;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onToggleChecked;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (block.type == NoteBlockType.divider) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
        child: Row(
          children: [
            Expanded(child: Divider(color: colors.neutrals.border)),
            IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onDelete),
          ],
        ),
      );
    }

    final style = switch (block.type) {
      NoteBlockType.heading => context.textStyles.title3.copyWith(color: colors.neutrals.ink),
      NoteBlockType.quote => context.textStyles.body.copyWith(color: colors.neutrals.ink2, fontStyle: FontStyle.italic),
      NoteBlockType.code => context.textStyles.mono.copyWith(color: colors.neutrals.ink),
      _ => context.textStyles.body.copyWith(color: colors.neutrals.ink),
    };

    Widget field = TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      maxLines: null,
      style: style,
      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
    );

    if (block.type == NoteBlockType.code) {
      field = Container(padding: const EdgeInsets.all(LifeSpace.s8), color: colors.neutrals.surfaceAlt, child: field);
    } else if (block.type == NoteBlockType.quote) {
      field = Container(
        padding: const EdgeInsets.only(left: LifeSpace.s12),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: colors.neutrals.border, width: 3))),
        child: field,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.type == NoteBlockType.checklistItem)
            Checkbox(value: block.checked, onChanged: (_) => onToggleChecked())
          else if (block.type == NoteBlockType.bullet)
            Padding(
              padding: const EdgeInsets.only(top: LifeSpace.s12, right: LifeSpace.s8),
              child: Text('•', style: context.textStyles.body.copyWith(color: colors.neutrals.ink)),
            ),
          Expanded(child: field),
          IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onDelete),
        ],
      ),
    );
  }
}
