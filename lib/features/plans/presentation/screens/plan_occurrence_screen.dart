import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/widgets/occurrence_sheet.dart';

/// Full-screen fallback for the `/occurrence/:id` deep link and the
/// `/plans/:id/occurrence/:occId` route — same content as [OccurrenceSheet],
/// just not presented as a sheet.
class PlanOccurrenceScreen extends ConsumerWidget {
  const PlanOccurrenceScreen({required this.occurrenceId, super.key});

  final String occurrenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOccurrence = ref.watch(occurrenceByIdProvider(occurrenceId));
    return asyncOccurrence.when(
      loading: () =>
          const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: const LErrorState(message: "Couldn't load this occurrence."),
      ),
      data: (occurrence) {
        if (occurrence == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const LErrorState(
              message: 'This occurrence no longer exists.',
            ),
          );
        }
        final asyncPlan = ref.watch(planByIdProvider(occurrence.planId));
        return asyncPlan.when(
          loading: () =>
              const Scaffold(body: Center(child: LLoadingShimmer(width: 200))),
          error: (error, stack) => Scaffold(
            appBar: AppBar(),
            body: const LErrorState(message: "Couldn't load this plan."),
          ),
          data: (plan) {
            if (plan == null) {
              return Scaffold(
                appBar: AppBar(),
                body: const LErrorState(message: 'This plan no longer exists.'),
              );
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Occurrence')),
              body: OccurrenceSheet(occurrence: occurrence, plan: plan),
            );
          },
        );
      },
    );
  }
}
