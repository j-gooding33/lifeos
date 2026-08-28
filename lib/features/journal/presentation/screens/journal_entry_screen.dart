import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_journal_entry.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:life_os/design/components/l_block_editor.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/journal/application/journal_providers.dart';

const _moods = [1, 2, 3, 4, 5];
const _moodEmoji = {1: '😞', 2: '🙁', 3: '😐', 4: '🙂', 5: '😄'};
const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// §22.1's entry screen. The auto-generated "what you completed / watched /
/// spent" context strip is deferred — see DECISIONS.md; this pass ships the
/// entry itself: mood, and the same block editor Notes uses.
class JournalEntryScreen extends ConsumerWidget {
  const JournalEntryScreen({required this.date, super.key});

  final CivilDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncEntry = ref.watch(journalEntryByDateProvider(date));
    return asyncEntry.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(appBar: AppBar(), body: const LErrorState(message: "Couldn't load this entry.")),
      data: (entry) {
        if (entry == null) {
          return Scaffold(backgroundColor: colors.neutrals.bg, appBar: AppBar(), body: const LErrorState(message: 'This entry no longer exists.'));
        }
        return _JournalEntryBody(key: ValueKey(entry.id), entry: entry);
      },
    );
  }
}

class _JournalEntryBody extends ConsumerStatefulWidget {
  const _JournalEntryBody({required this.entry, super.key});

  final AppJournalEntry entry;

  @override
  ConsumerState<_JournalEntryBody> createState() => _JournalEntryBodyState();
}

class _JournalEntryBodyState extends ConsumerState<_JournalEntryBody> {
  late List<NoteBlock> _blocks = List.of(widget.entry.blocks);
  late int? _mood = widget.entry.mood;
  var _dirty = false;

  Future<void> _save() async {
    await ref.read(journalRepositoryProvider).updateEntry(widget.entry.copyWith(blocks: _blocks, mood: _mood, clearMood: _mood == null));
    setState(() => _dirty = false);
  }

  void _setMood(int mood) {
    setState(() {
      _mood = _mood == mood ? null : mood;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = widget.entry.date;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text('${date.day} ${_monthNames[date.month - 1]} ${date.year}'),
        actions: [
          IconButton(icon: const Icon(Icons.check), tooltip: 'Save', onPressed: _dirty ? _save : null),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(LifeSpace.s16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final mood in _moods)
                  _MoodButton(
                    emoji: _moodEmoji[mood]!,
                    selected: _mood == mood,
                    onTap: () => _setMood(mood),
                  ),
              ],
            ),
            const SizedBox(height: LifeSpace.s20),
            LBlockEditor(
              blocks: widget.entry.blocks,
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

class _MoodButton extends StatelessWidget {
  const _MoodButton({required this.emoji, required this.selected, required this.onTap});

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(LifeSpace.s8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? colors.accent.soft : Colors.transparent,
          border: Border.all(color: selected ? colors.accent.base : Colors.transparent, width: 2),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
