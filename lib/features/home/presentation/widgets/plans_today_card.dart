import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_card.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:life_os/routing/routes.dart';

/// §5.3's `plansToday` — today's non-habit occurrences with inline
/// complete. Habit-kind plans get their own `habits` card instead.
class PlansTodayCard extends ConsumerWidget {
  const PlansTodayCard({required this.snapshot, super.key});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (snapshot.plansToday.isEmpty) return const SizedBox.shrink();

    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LSectionHeader(title: 'Plans today'),
          const SizedBox(height: LifeSpace.s8),
          for (final occurrence in snapshot.plansToday)
            _PlanRow(occurrence: occurrence, plan: snapshot.plansTodayTitles[occurrence.planId]),
        ],
      ),
    );
  }
}

class _PlanRow extends ConsumerWidget {
  const _PlanRow({required this.occurrence, required this.plan});

  final AppOccurrence occurrence;
  final AppPlan? plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final completed = occurrence.status == OccurrenceStatus.completed;

    return InkWell(
      onTap: plan == null ? null : () => context.push(Routes.planDetail.replaceFirst(':id', plan!.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s4),
        child: Row(
          children: [
            LCheckCircle(
              checked: completed,
              semanticLabel: plan?.title ?? 'Plan',
              onChanged: (checked) {
                final currentPlan = plan;
                if (currentPlan == null) return;
                final repository = ref.read(homePlanRepositoryProvider);
                if (checked) {
                  repository.completeOccurrence(occurrence, currentPlan);
                } else {
                  repository.uncompleteOccurrence(occurrence, currentPlan);
                }
              },
            ),
            Expanded(
              child: Text(
                plan?.title ?? 'Plan',
                style: context.textStyles.body.copyWith(color: colors.neutrals.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
