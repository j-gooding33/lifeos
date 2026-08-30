import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/first_value.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/repositories/event_repository.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/features/home/application/briefing.dart';
import 'package:life_os/features/home/application/home_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'briefing_providers.g.dart';

/// §19.9. Both periods share one shape — the fields the other period
/// doesn't use are left at their empty default rather than the class
/// forking in two, since the screen already branches on [period] anyway.
class BriefingData {
  const BriefingData({
    required this.period,
    required this.sentence,
    this.taskCount = 0,
    this.occurrenceCount = 0,
    this.nearestDeadlineTitle,
    this.freeWindows = const [],
    this.completedToday = const [],
    this.tomorrowCount = 0,
  });

  final BriefingPeriod period;
  final String sentence;
  final int taskCount;
  final int occurrenceCount;
  final String? nearestDeadlineTitle;
  final List<FreeTimeWindow> freeWindows;
  final List<String> completedToday;
  final int tomorrowCount;
}

/// Own instance rather than `calendar/`'s provider — same rule-4 reason
/// as every other cross-feature repository in `home/`.
@Riverpod(keepAlive: true)
EventRepository briefingEventRepository(Ref ref) => EventRepository(EventDao(ref.watch(appDatabaseProvider)));

/// Resolves a pending occurrence's wall-clock busy interval for the
/// free-time computation: its own [AppOccurrence.scheduledTime], falling
/// back to the plan's [AppPlan.timeOfDay] (the same fallback
/// `NotificationScheduler` already uses), and needs [AppPlan.durationMinutes]
/// to know when it ends. `null` when either is missing — an occurrence
/// with no known time or length can't honestly block a calendar slot.
(DateTime, DateTime)? _occurrenceBusyInterval(AppOccurrence occurrence, AppPlan? plan, CivilDate today) {
  final duration = plan?.durationMinutes;
  if (duration == null || duration <= 0) return null;
  final time = occurrence.scheduledTime ?? plan?.timeOfDay;
  final start = civilDateTimeAt(today, time);
  if (start == null) return null;
  return (start, start.add(Duration(minutes: duration)));
}

@riverpod
Future<BriefingData> briefing(Ref ref, BriefingPeriod period) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final today = CivilDate.fromDateTime(DateTime.now());
  final taskRepository = ref.watch(homeTaskRepositoryProvider);
  final planRepository = ref.watch(homePlanRepositoryProvider);

  if (period == BriefingPeriod.morning) {
    final todayTasks = await firstValue(taskRepository.watchAllDueOn(userId, today));
    final futureTasks = await firstValue(taskRepository.watchFutureDatedOnly(userId, today));
    final incompleteToday = todayTasks.where((t) => t.completedAt == null).toList();
    final deadline = nearestDeadline([...incompleteToday, ...futureTasks]);

    final todayOccurrences = await firstValue(planRepository.watchOccurrencesInRange(userId, today, today));
    final pendingOccurrences = todayOccurrences.where((o) => o.status == OccurrenceStatus.pending).toList();

    final activePlans = await firstValue(planRepository.watchActive(userId));
    final habitPlans = await firstValue(planRepository.watchHabits(userId));
    final plansById = {for (final p in [...activePlans, ...habitPlans]) p.id: p};

    final events = await firstValue(ref.watch(briefingEventRepositoryProvider).watchInRange(userId, today, today));
    final busy = <(DateTime, DateTime)>[
      for (final e in events)
        if (!e.allDay && e.endAt != null) (e.startAt, e.endAt!),
      for (final o in pendingOccurrences)
        if (_occurrenceBusyInterval(o, plansById[o.planId], today) case final interval?) interval,
    ];
    final now = DateTime.now();
    final dayEnd = DateTime(today.year, today.month, today.day, 22);
    final windows = now.isBefore(dayEnd) ? freeTimeWindows(busy: busy, dayStart: now, dayEnd: dayEnd) : const <FreeTimeWindow>[];

    return BriefingData(
      period: period,
      sentence: morningSentence(
        taskCount: incompleteToday.length,
        occurrenceCount: pendingOccurrences.length,
        nearestDeadline: deadline,
      ),
      taskCount: incompleteToday.length,
      occurrenceCount: pendingOccurrences.length,
      nearestDeadlineTitle: deadline?.title,
      freeWindows: windows,
    );
  }

  final todayTasks = await firstValue(taskRepository.watchAllDueOn(userId, today));
  final completedTaskTitles = todayTasks.where((t) => t.completedAt != null).map((t) => t.title).toList();

  final todayOccurrences = await firstValue(planRepository.watchOccurrencesInRange(userId, today, today));
  final completedOccurrences = todayOccurrences.where((o) => o.status == OccurrenceStatus.completed).toList();
  final activePlans = await firstValue(planRepository.watchActive(userId));
  final habitPlans = await firstValue(planRepository.watchHabits(userId));
  final plansById = {for (final p in [...activePlans, ...habitPlans]) p.id: p};
  final completedOccurrenceTitles = [
    for (final o in completedOccurrences)
      if (plansById[o.planId]?.title case final title?) title,
  ];

  final tomorrow = today.addDays(1);
  final tomorrowTasks = await firstValue(taskRepository.watchAllDueOn(userId, tomorrow));
  final tomorrowOccurrences = await firstValue(planRepository.watchOccurrencesInRange(userId, tomorrow, tomorrow));
  final tomorrowCount = tomorrowTasks.length + tomorrowOccurrences.where((o) => o.status == OccurrenceStatus.pending).length;
  final completedToday = [...completedTaskTitles, ...completedOccurrenceTitles];

  return BriefingData(
    period: period,
    sentence: eveningSentence(completedCount: completedToday.length, tomorrowCount: tomorrowCount),
    completedToday: completedToday,
    tomorrowCount: tomorrowCount,
  );
}
