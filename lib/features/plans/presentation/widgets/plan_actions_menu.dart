import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §7.4: "Long-press → pause, edit, duplicate, archive, delete" — shared by
/// the Plans list row (long-press) and the Plan detail screen's "⋯" button.
Future<void> showPlanActionsMenu({
  required BuildContext context,
  required WidgetRef ref,
  required AppPlan plan,
  required Offset position,
  VoidCallback? onDeleted,
}) async {
  final repository = ref.read(planRepositoryProvider);
  await LMenu.showAt(
    context: context,
    position: position,
    items: [
      if (plan.pauseFrom != null)
        LMenuItem(
          label: 'Resume',
          icon: Icons.play_arrow_outlined,
          onTap: () => repository.resumePlan(plan.id),
        )
      else
        LMenuItem(
          label: 'Pause',
          icon: Icons.pause_outlined,
          onTap: () => _pickPauseUntil(context, ref, plan),
        ),
      LMenuItem(
        label: 'Edit',
        icon: Icons.edit_outlined,
        onTap: () => context.push(Routes.planEdit.replaceFirst(':id', plan.id)),
      ),
      LMenuItem(
        label: 'Duplicate',
        icon: Icons.copy_outlined,
        onTap: () => repository.duplicatePlan(plan),
      ),
      if (plan.isArchived)
        LMenuItem(
          label: 'Unarchive',
          icon: Icons.unarchive_outlined,
          onTap: () => repository.unarchivePlan(plan.id),
        )
      else
        LMenuItem(
          label: 'Archive',
          icon: Icons.archive_outlined,
          onTap: () => repository.archivePlan(plan.id),
        ),
      LMenuItem(
        label: 'Delete',
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () => _confirmDelete(context, ref, plan, onDeleted),
      ),
    ],
  );
}

Future<void> _pickPauseUntil(
  BuildContext context,
  WidgetRef ref,
  AppPlan plan,
) async {
  final until = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 7)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (until == null) return;
  await ref
      .read(planRepositoryProvider)
      .pausePlan(plan.id, until: CivilDate.fromDateTime(until));
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  AppPlan plan,
  VoidCallback? onDeleted,
) async {
  final confirmed = await LConfirmDialog.show(
    context,
    title: 'Delete this plan?',
    message: 'This cannot be undone.',
  );
  if (confirmed) {
    await ref.read(planRepositoryProvider).deletePlan(plan.id);
    onDeleted?.call();
  }
}
