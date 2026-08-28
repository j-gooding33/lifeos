import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/design/components/l_day_rail.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/calendar/application/calendar_providers.dart';
import 'package:life_os/features/calendar/application/month_grid.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';
import 'package:life_os/features/plans/presentation/plan_colour.dart';
import 'package:life_os/features/plans/presentation/widgets/occurrence_sheet.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:life_os/routing/routes.dart';

enum _CalendarView { day, month }

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
const _weekdayFull = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// A calendar item is one of a task, an event, or a plan occurrence — all
/// three are real data sources; habit occurrence dates are already plan
/// occurrences (§7.1's "habits are plans"), so no separate habit source is
/// needed. Goal milestones, scheduled films/study sessions and reminders
/// from §14.1's full list stay off the timeline until Goals (M8), the
/// Plan↔Library link (M12) and Notifications (M17) exist — see
/// DECISIONS.md.
class _CalendarItem {
  const _CalendarItem({
    required this.title,
    required this.date,
    required this.color,
    required this.onTap,
    this.timeOfDay,
  });

  final String title;
  final CivilDate date;
  final String? timeOfDay;
  final Color color;
  final VoidCallback onTap;

  /// Minutes since midnight, or null for an all-day/no-time item.
  int? get minuteOfDay {
    if (timeOfDay == null) return null;
    final parts = timeOfDay!.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/// §14. One timeline merging events, tasks with due times, and plan
/// occurrences. Month and Day views only — Week and 3-day are deferred
/// (see DECISIONS.md), as is true pinch-to-morph between views in favour
/// of a plain segmented toggle.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  var _view = _CalendarView.month;
  late CivilDate _selectedDate;
  late CivilDate _monthStart;

  @override
  void initState() {
    super.initState();
    final today = CivilDate.fromDateTime(DateTime.now());
    _selectedDate = today;
    _monthStart = CivilDate(today.year, today.month, 1);
  }

  bool get _isTodayVisible {
    final today = CivilDate.fromDateTime(DateTime.now());
    if (_view == _CalendarView.day) return _selectedDate == today;
    return today.year == _monthStart.year && today.month == _monthStart.month;
  }

  void _goToToday() {
    final today = CivilDate.fromDateTime(DateTime.now());
    setState(() {
      _selectedDate = today;
      _monthStart = CivilDate(today.year, today.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (!_isTodayVisible)
            TextButton(onPressed: _goToToday, child: const Text('Today')),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New event',
            onPressed: () => context.push(
              Routes.calendarEvent.replaceFirst(':id', 'new'),
              extra: DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_CalendarView>(
              segments: const {
                _CalendarView.day: 'Day',
                _CalendarView.month: 'Month',
              },
              selected: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
          ),
          Expanded(
            child: _view == _CalendarView.day
                ? _DayView(
                    date: _selectedDate,
                    onChangeDate: (d) => setState(() => _selectedDate = d),
                  )
                : _MonthView(
                    monthStart: _monthStart,
                    selectedDate: _selectedDate,
                    onChangeMonth: (m) => setState(() => _monthStart = m),
                    onSelectDay: (d) => setState(() => _selectedDate = d),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Watches tasks/events/occurrences for [from]..[through] and hands the
/// combined, plan-enriched list to [builder] — the one place all three
/// range queries (§14.5) are issued and merged.
class _CalendarData extends ConsumerWidget {
  const _CalendarData({
    required this.from,
    required this.through,
    required this.builder,
  });

  final CivilDate from;
  final CivilDate through;
  final Widget Function(BuildContext, WidgetRef, List<_CalendarItem>) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksDueInRangeProvider(from, through));
    final asyncEvents = ref.watch(eventsInRangeProvider(from, through));
    final asyncOccurrences = ref.watch(
      occurrencesInRangeProvider(from, through),
    );
    final asyncActivePlans = ref.watch(activePlansProvider);
    final asyncHabitPlans = ref.watch(habitPlansProvider);

    final tasks = asyncTasks.value;
    final events = asyncEvents.value;
    final occurrences = asyncOccurrences.value;
    final activePlans = asyncActivePlans.value;
    final habitPlans = asyncHabitPlans.value;

    if (tasks == null ||
        events == null ||
        occurrences == null ||
        activePlans == null ||
        habitPlans == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = context.colors;
    final plansById = {
      for (final p in [...activePlans, ...habitPlans]) p.id: p,
    };

    final items = <_CalendarItem>[
      for (final task in tasks.where((t) => t.dueDate != null))
        _CalendarItem(
          title: task.title,
          date: CivilDate.parse(task.dueDate!),
          timeOfDay: task.dueTime,
          color: colors.domain('tasks').base,
          onTap: () =>
              context.push(Routes.taskDetail.replaceFirst(':id', task.id)),
        ),
      for (final event in events)
        _CalendarItem(
          title: event.title,
          date: event.startDate,
          timeOfDay: event.allDay ? null : _timeOfDayFrom(event.startAt),
          color: event.colour == null
              ? colors.domain('events').base
              : resolvePlanColour(context, event.colour).base,
          onTap: () =>
              context.push(Routes.calendarEvent.replaceFirst(':id', event.id)),
        ),
      for (final occurrence in occurrences)
        if (plansById[occurrence.planId] case final plan?)
          _CalendarItem(
            title: plan.title,
            date: occurrence.scheduledDate,
            timeOfDay: occurrence.scheduledTime ?? plan.timeOfDay,
            color: resolvePlanColour(context, plan.colour).base,
            onTap: () => OccurrenceSheet.show(
              context,
              occurrence: occurrence,
              plan: plan,
            ),
          ),
    ];

    return builder(context, ref, items);
  }

  String _timeOfDayFrom(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.monthStart,
    required this.selectedDate,
    required this.onChangeMonth,
    required this.onSelectDay,
  });

  final CivilDate monthStart;
  final CivilDate selectedDate;
  final ValueChanged<CivilDate> onChangeMonth;
  final ValueChanged<CivilDate> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (gridStart, gridEnd) = monthGridBounds(monthStart);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onChangeMonth(monthStart.addMonths(-1)),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[monthStart.month - 1]} ${monthStart.year}',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: colors.neutrals.ink,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onChangeMonth(monthStart.addMonths(1)),
              ),
            ],
          ),
        ),
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
          flex: 3,
          child: _CalendarData(
            from: gridStart,
            through: gridEnd,
            builder: (context, ref, items) {
              final byDate = <CivilDate, List<_CalendarItem>>{};
              for (final item in items) {
                byDate.putIfAbsent(item.date, () => []).add(item);
              }
              final totalCells = CivilDate.daysBetween(gridStart, gridEnd) + 1;
              return GridView.builder(
                padding: const EdgeInsets.all(LifeSpace.s8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final date = gridStart.addDays(index);
                  final dayItems = byDate[date] ?? const [];
                  return _MonthCell(
                    date: date,
                    inMonth: date.month == monthStart.month,
                    selected: date == selectedDate,
                    dotColors: dayItems.take(3).map((i) => i.color).toList(),
                    onTap: () => onSelectDay(date),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          flex: 2,
          child: _CalendarData(
            from: selectedDate,
            through: selectedDate,
            builder: (context, ref, items) =>
                _Agenda(date: selectedDate, items: items),
          ),
        ),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.dotColors,
    required this.onTap,
  });

  final CivilDate date;
  final bool inMonth;
  final bool selected;
  final List<Color> dotColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? colors.accent.soft : null,
          borderRadius: BorderRadius.circular(8),
        ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final color in dotColors)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.date, required this.items});

  final CivilDate date;
  final List<_CalendarItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (items.isEmpty) {
      // A scroll view, not a bare `LEmptyState`: the agenda strip under a
      // small month grid can be shorter than the empty state's natural
      // size, and a hard `Column` overflow is worse than losing perfect
      // vertical centering in that cramped case.
      return const SingleChildScrollView(
        child: LEmptyState(
          icon: Icons.event_outlined,
          title: 'Nothing scheduled',
          message: 'This day is clear.',
        ),
      );
    }
    final sorted = [...items]
      ..sort((a, b) => (a.minuteOfDay ?? -1).compareTo(b.minuteOfDay ?? -1));
    return ListView(
      padding: const EdgeInsets.all(LifeSpace.s16),
      children: [
        for (final item in sorted)
          ListTile(
            onTap: item.onTap,
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              item.title,
              style: context.textStyles.body.copyWith(
                color: colors.neutrals.ink,
              ),
            ),
            trailing: item.timeOfDay == null
                ? null
                : Text(
                    item.timeOfDay!,
                    style: context.textStyles.mono.copyWith(
                      color: colors.neutrals.ink2,
                    ),
                  ),
          ),
      ],
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({required this.date, required this.onChangeDate});

  final CivilDate date;
  final ValueChanged<CivilDate> onChangeDate;

  static const _startHour = 6;
  static const _endHour = 23;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onChangeDate(date.addDays(-1)),
              ),
              Expanded(
                child: Text(
                  '${_weekdayFull[date.isoWeekday - 1]} ${date.day} ${_monthNames[date.month - 1]}',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: colors.neutrals.ink,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onChangeDate(date.addDays(1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _CalendarData(
            from: date,
            through: date,
            builder: (context, ref, items) {
              final allDay = items.where((i) => i.timeOfDay == null).toList();
              final timed = items.where((i) => i.timeOfDay != null).toList()
                ..sort((a, b) => a.minuteOfDay!.compareTo(b.minuteOfDay!));

              var windowStart = _startHour * 60;
              var windowEnd = _endHour * 60;
              for (final item in timed) {
                windowStart = windowStart < item.minuteOfDay!
                    ? windowStart
                    : item.minuteOfDay!;
                windowEnd = windowEnd > item.minuteOfDay!
                    ? windowEnd
                    : item.minuteOfDay!;
              }
              windowEnd = windowEnd + 30;
              final totalMinutes = (windowEnd - windowStart).clamp(60, 24 * 60);

              final today = CivilDate.fromDateTime(DateTime.now());
              double? progressFraction;
              if (date == today) {
                final now = TimeOfDay.now();
                final nowMinutes = now.hour * 60 + now.minute;
                if (nowMinutes >= windowStart && nowMinutes <= windowEnd) {
                  progressFraction = (nowMinutes - windowStart) / totalMinutes;
                }
              }

              return ListView(
                padding: const EdgeInsets.all(LifeSpace.s16),
                children: [
                  if (allDay.isNotEmpty) ...[
                    Text(
                      'All day',
                      style: context.textStyles.subhead.copyWith(
                        color: colors.neutrals.ink2,
                      ),
                    ),
                    for (final item in allDay)
                      ListTile(
                        onTap: item.onTap,
                        leading: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: context.textStyles.body.copyWith(
                            color: colors.neutrals.ink,
                          ),
                        ),
                      ),
                    const Divider(),
                  ],
                  if (timed.isEmpty)
                    const LEmptyState(
                      icon: Icons.schedule_outlined,
                      title: 'Nothing scheduled',
                      message: 'This day has no timed items.',
                    )
                  else
                    SizedBox(
                      height: timed.length * 64.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                              right: LifeSpace.s12,
                            ),
                            child: LDayRail(
                              height: timed.length * 64.0,
                              progressFraction: progressFraction,
                              itemFractions: [
                                for (final item in timed)
                                  (item.minuteOfDay! - windowStart) /
                                      totalMinutes,
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                for (final item in timed)
                                  ListTile(
                                    onTap: item.onTap,
                                    dense: true,
                                    leading: Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: item.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: context.textStyles.body.copyWith(
                                        color: colors.neutrals.ink,
                                      ),
                                    ),
                                    trailing: Text(
                                      item.timeOfDay!,
                                      style: context.textStyles.mono.copyWith(
                                        color: colors.neutrals.ink2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
