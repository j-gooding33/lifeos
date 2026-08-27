import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/widgets/link_media_sheet.dart';
import 'package:life_os/routing/routes.dart';

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatFullDate(CivilDate date) =>
    '${_weekdayNames[date.isoWeekday - 1]} ${date.day} ${_monthNames[date.month - 1]}';

/// §8.3. "The critical rule of this screen is that changing one occurrence
/// must not change the plan" — every action here edits `occurrence` alone;
/// only "Edit the whole plan" (visually separated, `ink2`) touches the
/// rule. §16.5's "choose a film" row is `_MediaLinkSection`, shown only
/// when `plan.mediaType` is set.
class OccurrenceSheet extends ConsumerWidget {
  const OccurrenceSheet({
    required this.occurrence,
    required this.plan,
    super.key,
  });

  final AppOccurrence occurrence;
  final AppPlan plan;

  static Future<void> show(
    BuildContext context, {
    required AppOccurrence occurrence,
    required AppPlan plan,
  }) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.45],
      builder: (context) => OccurrenceSheet(occurrence: occurrence, plan: plan),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final repository = ref.read(planRepositoryProvider);
    final dateLabel = occurrence.scheduledTime == null
        ? _formatFullDate(occurrence.scheduledDate)
        : '${_formatFullDate(occurrence.scheduledDate)} · ${occurrence.scheduledTime}';

    return Padding(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateLabel,
            style: context.textStyles.subhead.copyWith(
              color: colors.neutrals.ink2,
            ),
          ),
          Text(
            plan.title,
            style: context.textStyles.title3.copyWith(
              color: colors.neutrals.ink,
            ),
          ),
          const SizedBox(height: LifeSpace.s20),
          Row(
            children: [
              Expanded(
                child: LButton(
                  label: occurrence.isCompleted ? 'Completed' : 'Complete',
                  onPressed: occurrence.isCompleted
                      ? () => repository.uncompleteOccurrence(occurrence)
                      : () => _complete(context, ref, repository),
                ),
              ),
              const SizedBox(width: LifeSpace.s12),
              Expanded(
                child: LButton(
                  label: 'Skip',
                  variant: LButtonVariant.tonal,
                  onPressed: () => repository.skipOccurrence(occurrence),
                ),
              ),
            ],
          ),
          if (plan.mediaType != null) ...[
            const Divider(),
            _MediaLinkSection(occurrence: occurrence, plan: plan),
          ],
          const SizedBox(height: LifeSpace.s20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Move to…',
                  style: context.textStyles.body.copyWith(
                    color: colors.neutrals.ink,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    _move(context, ref, occurrence.scheduledDate.addDays(1)),
                child: const Text('Tomorrow'),
              ),
              TextButton(
                onPressed: () => _pickMoveDate(context, ref),
                child: const Text('Pick a date'),
              ),
            ],
          ),
          _actionRow(
            context,
            'Add a note',
            onTap: () => _addNote(context, ref),
          ),
          _actionRow(
            context,
            'Remove this date',
            onTap: () => _confirmRemove(context, ref),
          ),
          const Divider(),
          _actionRow(
            context,
            'Edit the whole plan',
            muted: true,
            onTap: () {
              Navigator.of(context).maybePop();
              context.push(Routes.planEdit.replaceFirst(':id', plan.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _actionRow(
    BuildContext context,
    String label, {
    required VoidCallback onTap,
    bool muted = false,
  }) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s12),
        child: Text(
          label,
          style: context.textStyles.body.copyWith(
            color: muted ? colors.neutrals.ink2 : colors.neutrals.ink,
          ),
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, PlanRepository repository) async {
    final result = await repository.completeOccurrence(occurrence, plan);
    if (!context.mounted) return;
    if (result.isOk && occurrence.linkedEntityType == 'libraryItem' && occurrence.linkedEntityId != null) {
      await _promptRatingIfNeeded(context, ref, occurrence.linkedEntityId!);
    }
  }

  /// §16.5: "opens an optional rating prompt" — skippable, and never shown
  /// again once the item already has a rating.
  Future<void> _promptRatingIfNeeded(BuildContext context, WidgetRef ref, String libraryItemId) async {
    final item = await ref.read(planMediaRepositoryProvider).watchById(libraryItemId).first;
    if (item == null || item.isRated || !context.mounted) return;
    var rating = 0.0;
    final saved = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Rate ${item.title}?'),
          content: LStarRating(rating: rating, onChanged: (value) => setState(() => rating = value)),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Skip')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(rating), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != null && saved > 0) {
      await ref.read(planMediaRepositoryProvider).setRating(libraryItemId, saved);
    }
  }

  Future<void> _move(BuildContext context, WidgetRef ref, CivilDate to) async {
    final repository = ref.read(planRepositoryProvider);
    final result = await repository.moveOccurrence(occurrence, plan, to: to);
    if (!context.mounted) return;
    await result.when(
      ok: (_) {
        unawaited(Navigator.of(context).maybePop());
        LToast.show(
          context,
          'Moved to ${_formatFullDate(to)}',
          actionLabel: 'Undo',
          onAction: () => repository.moveOccurrence(
            occurrence,
            plan,
            to: occurrence.scheduledDate,
            keepBoth: true,
          ),
        );
      },
      err: (failure) => _handleMoveConflict(context, ref, to, failure),
    );
  }

  Future<void> _handleMoveConflict(
    BuildContext context,
    WidgetRef ref,
    CivilDate to,
    Object failure,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("There's already one on that day."),
        content: const Text('Merge, or keep both?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('merge'),
            child: const Text('Merge'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('keepBoth'),
            child: const Text('Keep both'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    final repository = ref.read(planRepositoryProvider);
    await repository.moveOccurrence(
      occurrence,
      plan,
      to: to,
      mergeInto: choice == 'merge',
      keepBoth: choice == 'keepBoth',
    );
    if (context.mounted) Navigator.of(context).maybePop();
  }

  Future<void> _pickMoveDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !context.mounted) return;
    await _move(context, ref, CivilDate.fromDateTime(picked));
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: occurrence.note ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Note'),
        content: LTextField(controller: controller, placeholder: 'Add a note'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved ?? false) {
      final note = controller.text.trim();
      await ref
          .read(planRepositoryProvider)
          .setOccurrenceNote(occurrence.id, note.isEmpty ? null : note);
    }
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(
      context,
      title: 'Remove this date?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    final result = await ref
        .read(planRepositoryProvider)
        .removeOccurrence(occurrence.id);
    if (context.mounted) {
      result.when(
        ok: (_) {
          unawaited(Navigator.of(context).maybePop());
        },
        err: (_) {},
      );
    }
  }
}

MediaType? _parseMediaType(String? raw) {
  for (final type in MediaType.values) {
    if (type.name == raw) return type;
  }
  return null;
}

String _mediaNoun(MediaType type) => switch (type) {
  MediaType.film => 'film',
  MediaType.tv => 'show',
  MediaType.book => 'book',
};

class _MediaLinkSection extends ConsumerWidget {
  const _MediaLinkSection({required this.occurrence, required this.plan});

  final AppOccurrence occurrence;
  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = _parseMediaType(plan.mediaType);
    if (type == null) return const SizedBox.shrink();
    final colors = context.colors;
    final linkedId = occurrence.linkedEntityId;

    if (linkedId == null || occurrence.linkedEntityType != 'libraryItem') {
      return InkWell(
        onTap: () => LinkMediaSheet.show(
          context,
          mediaType: type,
          onPicked: (item) => ref.read(planRepositoryProvider).linkOccurrenceToLibraryItem(occurrence.id, item.id),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: LifeSpace.s12),
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: colors.accent.base),
              const SizedBox(width: LifeSpace.s8),
              Text('Choose a ${_mediaNoun(type)}', style: context.textStyles.body.copyWith(color: colors.accent.base)),
            ],
          ),
        ),
      );
    }

    final asyncItem = ref.watch(linkedLibraryItemProvider(linkedId));
    return asyncItem.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (item) {
        if (item == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: LifeSpace.s12),
          child: Row(
            children: [
              Expanded(
                child: Text(item.title, style: context.textStyles.body.copyWith(color: colors.neutrals.ink)),
              ),
              TextButton(
                onPressed: () => ref.read(planRepositoryProvider).unlinkOccurrence(occurrence.id),
                child: const Text('Unlink'),
              ),
            ],
          ),
        );
      },
    );
  }
}
