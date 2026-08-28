import 'package:flutter/material.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';

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

const _textEditableTypes = {
  NoteBlockType.paragraph,
  NoteBlockType.heading,
  NoteBlockType.checklistItem,
  NoteBlockType.bullet,
  NoteBlockType.quote,
  NoteBlockType.code,
};

/// §17.1's block editor, shared by Notes and Journal (§22.1 uses the same
/// `blocksJson` shape). Append-and-delete only; no drag-reorder. Merges
/// each block's `TextEditingController` into its `NoteBlock` on every
/// keystroke rather than only at save time, so a divider/image/linkCard
/// block (which has no controller) can never have its real `text: null`
/// clobbered by an unrelated save — the bug this replaced.
class LBlockEditor extends StatefulWidget {
  const LBlockEditor({required this.blocks, required this.onChanged, super.key});

  final List<NoteBlock> blocks;
  final ValueChanged<List<NoteBlock>> onChanged;

  @override
  State<LBlockEditor> createState() => _LBlockEditorState();
}

class _LBlockEditorState extends State<LBlockEditor> {
  late List<NoteBlock> _blocks = List.of(widget.blocks);
  late List<TextEditingController> _controllers = [for (final block in _blocks) TextEditingController(text: block.text ?? '')];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addBlock(NoteBlockType type) {
    setState(() {
      _blocks = [..._blocks, NoteBlock(type: type, text: type == NoteBlockType.divider ? null : '')];
      _controllers = [..._controllers, TextEditingController()];
    });
    widget.onChanged(_blocks);
  }

  void _deleteBlock(int index) {
    setState(() {
      _blocks = [..._blocks]..removeAt(index);
      _controllers.removeAt(index).dispose();
    });
    widget.onChanged(_blocks);
  }

  void _toggleChecked(int index) {
    setState(() => _blocks[index] = _blocks[index].copyWith(checked: !_blocks[index].checked));
    widget.onChanged(_blocks);
  }

  void _onTextChanged(int index) {
    if (_textEditableTypes.contains(_blocks[index].type)) {
      _blocks[index] = _blocks[index].copyWith(text: _controllers[index].text);
    }
    widget.onChanged(_blocks);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _blocks.length; i++)
          _BlockEditorRow(
            block: _blocks[i],
            controller: _controllers[i],
            onChanged: () => _onTextChanged(i),
            onToggleChecked: () => _toggleChecked(i),
            onDelete: () => _deleteBlock(i),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: _pickBlockType, icon: const Icon(Icons.add), label: const Text('Add block')),
        ),
      ],
    );
  }
}

class _BlockEditorRow extends StatelessWidget {
  const _BlockEditorRow({
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
