/// §17.1's block types. Stored as a JSON array, not HTML/Markdown, so a
/// future block type is an enum case + a JSON shape, never a parser
/// rewrite. `image`/`linkCard` round-trip through JSON already but have no
/// editor UI yet — see DECISIONS.md.
enum NoteBlockType { paragraph, heading, checklistItem, bullet, quote, divider, image, linkCard, code }

class NoteBlock {
  const NoteBlock({
    required this.type,
    this.text,
    this.checked = false,
    this.imageUrl,
    this.linkUrl,
  });

  factory NoteBlock.fromJson(Map<String, Object?> json) {
    return NoteBlock(
      type: NoteBlockType.values.firstWhere((t) => t.name == json['type'], orElse: () => NoteBlockType.paragraph),
      text: json['text'] as String?,
      checked: json['checked'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
    );
  }

  final NoteBlockType type;

  /// The block's text content — paragraph/heading/checklistItem/bullet/
  /// quote/code. Null for divider/image/linkCard.
  final String? text;

  /// checklistItem only.
  final bool checked;

  /// image block only (not yet settable from the editor UI).
  final String? imageUrl;

  /// linkCard block only (not yet settable from the editor UI).
  final String? linkUrl;

  Map<String, Object?> toJson() => {
    'type': type.name,
    if (text != null) 'text': text,
    if (checked) 'checked': checked,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (linkUrl != null) 'linkUrl': linkUrl,
  };

  NoteBlock copyWith({String? text, bool? checked}) {
    return NoteBlock(type: type, text: text ?? this.text, checked: checked ?? this.checked, imageUrl: imageUrl, linkUrl: linkUrl);
  }
}
