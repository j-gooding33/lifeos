import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/features/tasks/application/task_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

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
    required this.recent,
  });

  /// Capped at 6 (§5.3's `focus` card).
  final List<AppTask> focusItems;
  final int doneToday;
  final int totalToday;

  /// Next 7 days, keyed by civil date, counts only (§5.3's `upcoming` card).
  final Map<String, int> upcomingByDay;

  final List<AppTask> recent;

  bool get allDoneToday => totalToday > 0 && doneToday == totalToday;
  bool get hasNothingToday => totalToday == 0;
}

@riverpod
Future<HomeSnapshot> homeSnapshot(Ref ref) async {
  final allToday = await ref.watch(allTasksDueTodayProvider.future);
  final focusItems = await ref.watch(todayTasksProvider.future);
  final upcoming = await ref.watch(upcomingTasksProvider.future);
  final recent = await ref.watch(recentlyCreatedTasksProvider.future);

  final upcomingByDay = <String, int>{};
  for (final task in upcoming) {
    final date = task.dueDate;
    if (date == null) continue;
    upcomingByDay[date] = (upcomingByDay[date] ?? 0) + 1;
  }

  return HomeSnapshot(
    // Cap at 6 (§5.3) — Home never renders an unbounded list (§5.6).
    focusItems: focusItems.take(6).toList(),
    doneToday: allToday.where((t) => t.isCompleted).length,
    totalToday: allToday.length,
    upcomingByDay: upcomingByDay,
    recent: recent,
  );
}
