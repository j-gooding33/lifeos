import 'package:life_os/data/repositories/models/note_block.dart';

/// §17.1. "Rich enough to be useful, not a Notion clone." `plainText` is a
/// getter derived from [blocks], not a separately-maintained field on this
/// model — `NoteRepository` writes it to the `plainText` column on every
/// save, which is what a future search index would read (§17.1: "the
/// search index reads" it), but this class only ever computes it fresh.
class AppNote {
  AppNote({
    required this.id,
    required this.userId,
    this.title,
    this.blocks = const [],
    this.folderId,
    this.pinned = false,
    this.colour,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String? title;
  final List<NoteBlock> blocks;
  final String? folderId;
  final bool pinned;
  final String? colour;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get plainText => blocks.map((b) => b.text).whereType<String>().where((t) => t.isNotEmpty).join('\n');

  AppNote copyWith({
    String? title,
    bool clearTitle = false,
    List<NoteBlock>? blocks,
    String? folderId,
    bool? pinned,
    String? colour,
  }) {
    return AppNote(
      id: id,
      userId: userId,
      title: clearTitle ? null : (title ?? this.title),
      blocks: blocks ?? this.blocks,
      folderId: folderId ?? this.folderId,
      pinned: pinned ?? this.pinned,
      colour: colour ?? this.colour,
      createdAt: createdAt,
    );
  }
}
