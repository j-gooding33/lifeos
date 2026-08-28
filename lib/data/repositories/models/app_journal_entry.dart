import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/note_block.dart';

/// §22.1. One entry per day (`idx_journal_date` enforces `(userId, date)`
/// uniqueness among non-deleted rows) — editable any day, not just today.
/// Reuses [NoteBlock]/`blocksJson`, same as Notes (§17.1).
class AppJournalEntry {
  AppJournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    this.blocks = const [],
    this.mood,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final CivilDate date;
  final List<NoteBlock> blocks;

  /// 1 (worst) .. 5 (best), or null if not set.
  final int? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get plainText => blocks.map((b) => b.text).whereType<String>().where((t) => t.isNotEmpty).join('\n');

  AppJournalEntry copyWith({List<NoteBlock>? blocks, int? mood, bool clearMood = false}) {
    return AppJournalEntry(
      id: id,
      userId: userId,
      date: date,
      blocks: blocks ?? this.blocks,
      mood: clearMood ? null : (mood ?? this.mood),
      createdAt: createdAt,
    );
  }
}
