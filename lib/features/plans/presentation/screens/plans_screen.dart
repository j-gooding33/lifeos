import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/widgets/plan_row.dart';
import 'package:life_os/routing/routes.dart';

enum _PlanSegment { active, habits, paused, archived }

/// §7.4. Segmented Active/Habits/Paused/Archived list. Sorting is
/// alphabetical or creation order for now — "next due" and "completion
/// rate" sorts need a stats lookup per row and are deferred; see
/// DECISIONS.md.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  var _segment = _PlanSegment.active;
  var _alphabetical = false;

  @override
  void initState() {
    super.initState();
    // §9.5 trigger ("plan detail open" and friends) — also run once here,
    // on list open, so a rule change made elsewhere and a missed sweep
    // stay current without a true midnight job (see DECISIONS.md).
    Future.microtask(() => ref.read(plansMaintenanceProvider.future));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Plans'),
        actions: [
          IconButton(
            icon: Icon(_alphabetical ? Icons.sort_by_alpha : Icons.access_time),
            tooltip: _alphabetical
                ? 'Sorted A–Z'
                : 'Sorted by recently created',
            onPressed: () => setState(() => _alphabetical = !_alphabetical),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Calendar',
            onPressed: () => context.push(Routes.calendar),
          ),
          IconButton(
            icon: const Icon(Icons.track_changes_outlined),
            tooltip: 'Habit tracker',
            onPressed: () => context.push(Routes.habits),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_PlanSegment>(
              segments: const {
                _PlanSegment.active: 'Active',
                _PlanSegment.habits: 'Habits',
                _PlanSegment.paused: 'Paused',
                _PlanSegment.archived: 'Archived',
              },
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(child: _buildSegment()),
        ],
      ),
    );
  }

  Widget _buildSegment() {
    switch (_segment) {
      case _PlanSegment.active:
        return _PlanList(
          asyncPlans: ref.watch(activePlansProvider),
          emptyTitle: 'No active plans',
          alphabetical: _alphabetical,
          onRetry: () => ref.invalidate(activePlansProvider),
        );
      case _PlanSegment.habits:
        return _PlanList(
          asyncPlans: ref.watch(habitPlansProvider),
          emptyTitle: 'No habits yet',
          alphabetical: _alphabetical,
          onRetry: () => ref.invalidate(habitPlansProvider),
        );
      case _PlanSegment.paused:
        return _PlanList(
          asyncPlans: ref.watch(pausedPlansProvider),
          emptyTitle: 'Nothing paused',
          alphabetical: _alphabetical,
          onRetry: () => ref.invalidate(pausedPlansProvider),
        );
      case _PlanSegment.archived:
        return _PlanList(
          asyncPlans: ref.watch(archivedPlansProvider),
          emptyTitle: 'Nothing archived',
          alphabetical: _alphabetical,
          onRetry: () => ref.invalidate(archivedPlansProvider),
        );
    }
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.asyncPlans,
    required this.emptyTitle,
    required this.alphabetical,
    required this.onRetry,
  });

  final AsyncValue<List<AppPlan>> asyncPlans;
  final String emptyTitle;
  final bool alphabetical;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return asyncPlans.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: LifeSpace.s16),
        child: Column(
          children: [
            LLoadingShimmer(height: 56),
            SizedBox(height: LifeSpace.s8),
            LLoadingShimmer(height: 56),
          ],
        ),
      ),
      error: (error, stack) =>
          LErrorState(message: "Couldn't load plans.", onRetry: onRetry),
      data: (plans) {
        if (plans.isEmpty) {
          return LEmptyState(
            icon: Icons.repeat_outlined,
            title: emptyTitle,
            message: 'Add a plan with the + button.',
          );
        }
        final sorted = [...plans];
        if (alphabetical) {
          sorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
          itemCount: sorted.length,
          itemBuilder: (context, index) => PlanRow(plan: sorted[index]),
        );
      },
    );
  }
}
