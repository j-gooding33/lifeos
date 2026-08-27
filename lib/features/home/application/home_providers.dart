import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

/// One Upcoming row's worth of data — a day, or the undated bucket.
class UpcomingBucket {
  const UpcomingBucket({required this.count, required this.firstTitle});

  final int count;

  /// `null` when [count] is 0.
  final String? firstTitle;

  bool get isEmpty => count == 0;
}

/// §5.5: "a single HomeSnapshot provider that runs one composed query."
/// The composition here is over already-shared, already-cached task
/// providers rather than a hand-rolled combined SQL query — Plans/Events
/// don't exist yet (M6/M7), so today the only source feeding "focus" is
/// Tasks. When occurrences and events land, they join this same snapshot
/// rather than each card opening its own stream.
class HomeSnapshot {
  const HomeSnapshot({
    required this.focusItems,
    required this.doneToday,
    required this.totalToday,
    required this.upcomingByDay,
    required this.upcomingUndated,
    required this.recent,
  });

  /// Capped at 6 (§5.3's `focus` card).
  final List<AppTask> focusItems;
  final int doneToday;
  final int totalToday;

  /// Next 7 days, keyed by civil date (§5.3's `upcoming` card).
  final Map<String, UpcomingBucket> upcomingByDay;

  /// Upcoming tasks with no due date at all — item 6/7: these must still
  /// surface on Home, just not attached to any one day.
  final UpcomingBucket upcomingUndated;

  final List<AppTask> recent;

  bool get allDoneToday => totalToday > 0 && doneToday == totalToday;
  bool get hasNothingToday => totalToday == 0;

  bool get hasNothingUpcoming =>
      upcomingUndated.isEmpty && upcomingByDay.values.every((b) => b.isEmpty);
}

/// Pure — groups an already-fetched upcoming-task list into per-day buckets
/// plus one undated bucket (item 6/7). Split out from [homeSnapshot] itself
/// so it's unit-testable without a database.
({Map<String, UpcomingBucket> byDay, UpcomingBucket undated}) bucketUpcoming(List<AppTask> upcoming) {
  final byDay = <String, List<AppTask>>{};
  final undated = <AppTask>[];
  for (final task in upcoming) {
    final date = task.dueDate;
    if (date == null) {
      undated.add(task);
    } else {
      (byDay[date] ??= []).add(task);
    }
  }
  return (
    byDay: {
      for (final entry in byDay.entries)
        entry.key: UpcomingBucket(count: entry.value.length, firstTitle: entry.value.first.title),
    },
    undated: UpcomingBucket(count: undated.length, firstTitle: undated.isEmpty ? null : undated.first.title),
  );
}

@riverpod
Future<HomeSnapshot> homeSnapshot(Ref ref) async {
  final allToday = await ref.watch(allTasksDueTodayProvider.future);
  final focusItems = await ref.watch(todayTasksProvider.future);
  final upcoming = await ref.watch(upcomingTasksProvider.future);
  final recent = await ref.watch(recentlyCreatedTasksProvider.future);

  final bucketed = bucketUpcoming(upcoming);

  return HomeSnapshot(
    // Cap at 6 (§5.3) — Home never renders an unbounded list (§5.6).
    focusItems: focusItems.take(6).toList(),
    doneToday: allToday.where((t) => t.isCompleted).length,
    totalToday: allToday.length,
    upcomingByDay: bucketed.byDay,
    upcomingUndated: bucketed.undated,
    recent: recent,
  );
}
