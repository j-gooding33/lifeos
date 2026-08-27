import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/routing/routes.dart';

const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(CivilDate date) => '${date.day} ${_monthNames[date.month - 1]}';

/// §16.4/§16.5 "Schedule this" — offers existing plans of [item]'s media
/// type, or a way to create one. Picking a plan links [item] to its
/// earliest upcoming occurrence that isn't already linked to something
/// else; creating a plan is a separate screen, so this doesn't try to
/// link immediately after — reopen "Schedule this" once it exists.
class ScheduleThisSheet extends ConsumerWidget {
  const ScheduleThisSheet({required this.item, super.key});

  final AppLibraryItem item;

  static Future<void> show(BuildContext context, AppLibraryItem item) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.6],
      builder: (context) => ScheduleThisSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncPlans = ref.watch(plansForMediaTypeProvider(item.mediaType));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(LifeSpace.s20, LifeSpace.s20, LifeSpace.s20, LifeSpace.s8),
          child: Text('Schedule this', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
        ),
        LListTile(
          leading: const Icon(Icons.add),
          title: 'New plan',
          onTap: () {
            Navigator.of(context).pop();
            context.push(Routes.plansNew);
          },
        ),
        const Divider(height: 1),
        Flexible(
          child: asyncPlans.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(LifeSpace.s24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(LifeSpace.s24),
              child: LErrorState(
                message: "Couldn't load your plans.",
                onRetry: () => ref.invalidate(plansForMediaTypeProvider(item.mediaType)),
              ),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(LifeSpace.s24),
                  child: LEmptyState(
                    icon: Icons.event_repeat_outlined,
                    title: 'No matching plans yet',
                    message: 'Create one above.',
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return LListTile(title: plan.title, onTap: () => _scheduleOn(context, ref, plan));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _scheduleOn(BuildContext context, WidgetRef ref, AppPlan plan) async {
    final repository = ref.read(libraryPlanRepositoryProvider);
    final upcoming = await repository.watchUpcoming(plan.id).first;
    final free = upcoming.where((o) => o.linkedEntityId == null).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (free.isEmpty) {
      LToast.show(context, '"${plan.title}" has no free upcoming date — open it to add one.');
      return;
    }
    final occurrence = free.first;
    await repository.linkOccurrenceToLibraryItem(occurrence.id, item.id);
    if (context.mounted) {
      LToast.show(context, 'Scheduled for ${_formatDate(occurrence.scheduledDate)}');
    }
  }
}
