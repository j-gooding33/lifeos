import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_date_picker.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/school/application/school_providers.dart';

const _closureTypeLabels = {
  SchoolClosureType.holiday: 'Holiday',
  SchoolClosureType.halfTerm: 'Half-term',
  SchoolClosureType.inset: 'Inset day',
  SchoolClosureType.custom: 'Other',
};

/// M8 Part 33 — term dates (school is only "in session" on a date covered
/// by a term) plus closures within a term (half-terms, inset days) or
/// between terms (holidays). Both feed `isSchoolOpen()` in the pure
/// week-parity engine.
class SchoolTermsScreen extends ConsumerWidget {
  const SchoolTermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncTerms = ref.watch(schoolTermsProvider);
    final asyncClosures = ref.watch(schoolClosuresProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Term dates')),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LSectionHeader(title: 'Terms'),
              TextButton(onPressed: () => _TermSheet.show(context, ref), child: const Text('Add')),
            ],
          ),
          asyncTerms.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => LErrorState(message: "Couldn't load terms.", onRetry: () => ref.invalidate(schoolTermsProvider)),
            data: (terms) {
              if (terms.isEmpty) {
                return const LEmptyState(icon: Icons.event_outlined, title: 'No terms yet', message: 'Add your first term above.');
              }
              return Column(
                children: [
                  for (final term in terms)
                    LListTile(
                      title: term.title,
                      subtitle: '${term.startDate} to ${term.endDate}',
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await LConfirmDialog.show(context, title: 'Delete this term?', message: 'This cannot be undone.');
                          if (confirmed) await ref.read(schoolRepositoryProvider).deleteTerm(term.id);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: LifeSpace.s24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LSectionHeader(title: 'Closures'),
              TextButton(onPressed: () => _ClosureSheet.show(context, ref), child: const Text('Add')),
            ],
          ),
          asyncClosures.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => LErrorState(message: "Couldn't load closures.", onRetry: () => ref.invalidate(schoolClosuresProvider)),
            data: (closures) {
              if (closures.isEmpty) {
                return const LEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No closures yet',
                  message: 'Half-terms, inset days, and holidays go here.',
                );
              }
              return Column(
                children: [
                  for (final closure in closures)
                    LListTile(
                      title: closure.title,
                      subtitle: '${_closureTypeLabels[closure.type]} · ${closure.startDate} to ${closure.endDate}',
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await LConfirmDialog.show(context, title: 'Delete this closure?', message: 'This cannot be undone.');
                          if (confirmed) await ref.read(schoolRepositoryProvider).deleteClosure(closure.id);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TermSheet extends ConsumerStatefulWidget {
  const _TermSheet();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return LSheet.show<void>(context: context, snapPoints: const [0.55], builder: (context) => const _TermSheet());
  }

  @override
  ConsumerState<_TermSheet> createState() => _TermSheetState();
}

class _TermSheetState extends ConsumerState<_TermSheet> {
  final _titleController = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _start == null || _end == null) return;
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(schoolRepositoryProvider).saveTerm(
      userId: userId,
      title: title,
      startDate: _isoDate(_start!),
      endDate: _isoDate(_end!),
    );
    if (mounted) Navigator.of(context).pop();
  }

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New term', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s16),
          LTextField(controller: _titleController, label: 'Title', outlined: true, autofocus: true),
          const SizedBox(height: LifeSpace.s16),
          Text('Starts', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s4),
          LDatePicker(date: _start, onChanged: (d) => setState(() => _start = d)),
          const SizedBox(height: LifeSpace.s12),
          Text('Ends', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s4),
          LDatePicker(date: _end, onChanged: (d) => setState(() => _end = d)),
          const SizedBox(height: LifeSpace.s20),
          LButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}

class _ClosureSheet extends ConsumerStatefulWidget {
  const _ClosureSheet();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return LSheet.show<void>(context: context, snapPoints: const [0.6], builder: (context) => const _ClosureSheet());
  }

  @override
  ConsumerState<_ClosureSheet> createState() => _ClosureSheetState();
}

class _ClosureSheetState extends ConsumerState<_ClosureSheet> {
  final _titleController = TextEditingController();
  var _type = SchoolClosureType.holiday;
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _start == null || _end == null) return;
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(schoolRepositoryProvider).saveClosure(
      userId: userId,
      title: title,
      type: _type,
      startDate: _isoDate(_start!),
      endDate: _isoDate(_end!),
    );
    if (mounted) Navigator.of(context).pop();
  }

  String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(LifeSpace.s20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New closure', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
          const SizedBox(height: LifeSpace.s16),
          LTextField(controller: _titleController, label: 'Title', outlined: true, autofocus: true),
          const SizedBox(height: LifeSpace.s16),
          LSegmented<SchoolClosureType>(segments: _closureTypeLabels, selected: _type, onChanged: (v) => setState(() => _type = v)),
          const SizedBox(height: LifeSpace.s16),
          Text('Starts', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s4),
          LDatePicker(date: _start, onChanged: (d) => setState(() => _start = d)),
          const SizedBox(height: LifeSpace.s12),
          Text('Ends', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
          const SizedBox(height: LifeSpace.s4),
          LDatePicker(date: _end, onChanged: (d) => setState(() => _end = d)),
          const SizedBox(height: LifeSpace.s20),
          LButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}
