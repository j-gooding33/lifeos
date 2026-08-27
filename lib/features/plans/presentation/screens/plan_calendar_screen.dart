import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/calendar/application/month_grid.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/occurrence_status_style.dart';
import 'package:life_os/features/plans/presentation/widgets/occurrence_sheet.dart';

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

/// §8.2. Month grid, plan colour only. Long-press a blank day to add an
/// extra, non-generated occurrence there.
class PlanCalendarScreen extends ConsumerStatefulWidget {
  const PlanCalendarScreen({required this.planId, super.key});

  final String planId;

  @override
  ConsumerState<PlanCalendarScreen> createState() => _PlanCalendarScreenState();
}

class _PlanCalendarScreenState extends ConsumerState<PlanCalendarScreen> {
  late CivilDate _monthStart;

  @override
  void initState() {
    super.initState();
    final today = CivilDate.fromDateTime(DateTime.now());
    _monthStart = CivilDate(today.year, today.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asyncPlan = ref.watch(planByIdProvider(widget.planId));
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
        final (gridStart, gridEnd) = monthGridBounds(_monthStart);
        final asyncOccurrences = ref.watch(
          planOccurrencesInRangeProvider(plan.id, gridStart, gridEnd),
        );
        return Scaffold(
          backgroundColor: colors.neutrals.bg,
          appBar: AppBar(title: Text('${plan.title} calendar')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LifeSpace.s16,
                  vertical: LifeSpace.s8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(
                        () => _monthStart = _monthStart.addMonths(-1),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthNames[_monthStart.month - 1]} ${_monthStart.year}',
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyStrong.copyWith(
                          color: colors.neutrals.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(
                        () => _monthStart = _monthStart.addMonths(1),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: asyncOccurrences.when(
                  loading: () =>
                      const Center(child: LLoadingShimmer(width: 200)),
                  error: (error, stack) =>
                      const LErrorState(message: "Couldn't load occurrences."),
                  data: (occurrences) => _MonthGrid(
                    monthStart: _monthStart,
                    plan: plan,
                    occurrences: occurrences,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
    required this.monthStart,
    required this.plan,
    required this.occurrences,
  });

  final CivilDate monthStart;
  final AppPlan plan;
  final List<AppOccurrence> occurrences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final byDate = {for (final o in occurrences) o.scheduledDate: o};
    final (gridStart, gridEnd) = monthGridBounds(monthStart);
    final totalCells = CivilDate.daysBetween(gridStart, gridEnd) + 1;

    return Column(
      children: [
        Row(
          children: [
            for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: context.textStyles.caption.copyWith(
                      color: colors.neutrals.ink3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(LifeSpace.s8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final date = gridStart.addDays(index);
              final inMonth = date.month == monthStart.month;
              final occurrence = byDate[date];
              return _DayCell(
                date: date,
                inMonth: inMonth,
                occurrence: occurrence,
                plan: plan,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.occurrence,
    required this.plan,
  });

  final CivilDate date;
  final bool inMonth;
  final AppOccurrence? occurrence;
  final AppPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return InkWell(
      onTap: occurrence == null
          ? null
          : () => OccurrenceSheet.show(
              context,
              occurrence: occurrence!,
              plan: plan,
            ),
      onLongPress: occurrence != null ? null : () => _addExtra(context, ref),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: context.textStyles.caption.copyWith(
              color: inMonth ? colors.neutrals.ink : colors.neutrals.ink3,
            ),
          ),
          const SizedBox(height: 2),
          if (occurrence != null)
            Icon(
              occurrence!.originalDate != null &&
                      occurrence!.status == OccurrenceStatus.pending
                  ? Icons.subdirectory_arrow_right
                  : occurrenceStatusIcon(occurrence!.status),
              size: 14,
              color: occurrenceStatusColor(context, occurrence!.status),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Future<void> _addExtra(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add an extra occurrence?'),
        content: Text(
          'Adds a one-off occurrence of "${plan.title}" on this day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(planRepositoryProvider).addExtraOccurrence(plan, date);
    }
  }
}
