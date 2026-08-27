import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';

/// M8 Part 5/22: marking watched/finished — a date (defaulting to today,
/// editable), an optional rating, and an optional short log, all in one
/// sheet. Reused for editing later (Part 5: "the log should be editable"),
/// since it pre-fills from whatever the item already has.
class MarkWatchedSheet extends ConsumerStatefulWidget {
  const MarkWatchedSheet({required this.item, this.verb = 'Watched', super.key});

  final AppLibraryItem item;

  /// "Watched" for films/TV, "Finished" for books (Part 22).
  final String verb;

  static Future<void> show(BuildContext context, AppLibraryItem item, {String verb = 'Watched'}) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.6],
      builder: (context) => MarkWatchedSheet(item: item, verb: verb),
    );
  }

  @override
  ConsumerState<MarkWatchedSheet> createState() => _MarkWatchedSheetState();
}

class _MarkWatchedSheetState extends ConsumerState<MarkWatchedSheet> {
  late DateTime _date;
  late double _rating;
  late final TextEditingController _logController;

  @override
  void initState() {
    super.initState();
    _date = widget.item.finishedAt ?? DateTime.now();
    _rating = widget.item.rating ?? 0;
    _logController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = ref.read(libraryItemRepositoryProvider);
    await repository.markWatched(widget.item.id, watchedDate: _date, rating: _rating == 0 ? null : _rating);
    final log = _logController.text.trim();
    await repository.setNotes(widget.item.id, log.isEmpty ? null : log);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.item.title, style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s20),
          Text('${widget.verb}:', style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s8),
          LDatePicker(date: _date, lastDate: DateTime.now(), onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: LifeSpace.s20),
          Text('Rating (optional):', style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s8),
          LStarRating(rating: _rating, size: 32, onChanged: (v) => setState(() => _rating = v)),
          const SizedBox(height: LifeSpace.s20),
          Text('Log (optional):', style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s8),
          LTextField(controller: _logController, placeholder: 'What did you think?'),
          const SizedBox(height: LifeSpace.s24),
          LButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
