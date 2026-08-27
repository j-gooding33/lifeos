import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_check_circle.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_icons.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/rule_description.dart';
import 'package:life_os/features/plans/presentation/widgets/plan_actions_menu.dart';
import 'package:life_os/routing/routes.dart';

/// §7.4's list row: icon in a colour-soft circle, title, rhythm in `mono`,
/// and a right-hand state that depends on whether *today's* occurrence
/// (if any) is pending, done, or doesn't exist.
class PlanRow extends ConsumerWidget {
  const PlanRow({required this.plan, super.key});

  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final planColour = resolvePlanColour(context, plan.colour);
    final asyncToday = ref.watch(todayOccurrenceForPlanProvider(plan.id));
    final isDoneToday = asyncToday.value?.isCompleted ?? false;

    final row = GestureDetector(
      onLongPressStart: (details) => showPlanActionsMenu(
        context: context,
        ref: ref,
        plan: plan,
        position: details.globalPosition,
      ),
      child: InkWell(
        onTap: () =>
            context.push(Routes.planDetail.replaceFirst(':id', plan.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LifeSpace.s16,
            vertical: LifeSpace.s8,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: planColour.soft,
                child: Icon(
                  planIconFor(plan.icon),
                  color: planColour.base,
                  size: 20,
                ),
              ),
              const SizedBox(width: LifeSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plan.title,
                      style: context.textStyles.body.copyWith(
                        color: colors.neutrals.ink,
                      ),
                    ),
                    Text(
                      describeRule(plan.rule),
                      style: context.textStyles.mono.copyWith(
                        color: colors.neutrals.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LifeSpace.s12),
              _trailing(context, ref, asyncToday.value),
            ],
          ),
        ),
      ),
    );

    if (!isDoneToday) return row;
    return Opacity(opacity: 0.6, child: row);
  }

  Widget _trailing(BuildContext context, WidgetRef ref, AppOccurrence? today) {
    final colors = context.colors;
    if (today == null) {
      final next = const RecurrenceEngine().next(
        plan.rule,
        CivilDate.fromDateTime(DateTime.now()),
        1,
      );
      return Text(
        next.isEmpty ? '—' : next.first.toIso(),
        style: context.textStyles.mono.copyWith(color: colors.neutrals.ink3),
      );
    }
    if (today.isCompleted) {
      return Icon(Icons.check_circle, color: colors.semantic('success').base);
    }
    return LCheckCircle(
      checked: false,
      semanticLabel: 'Complete ${plan.title}',
      onChanged: (_) =>
          ref.read(planRepositoryProvider).completeOccurrence(today, plan),
    );
  }
}
