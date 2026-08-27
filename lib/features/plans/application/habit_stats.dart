import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';

/// §13.2's full-year heatmap. Pure — no database, no Flutter — so every
/// boundary (before the habit started, today, the future) is directly
/// testable. One value per day, oldest first, 365 entries ending on
/// [today]; feed straight into `LHeatmapGrid(columns: 7)` for a
/// week-per-line year view.
List<double?> computeYearHeatmap(
  List<AppOccurrence> occurrences, {
  required CivilDate today,
  required CivilDate habitStart,
}) {
  final byDate = {for (final o in occurrences) o.scheduledDate: o.status};
  return [
    for (var i = 364; i >= 0; i--) _dayValue(byDate[today.addDays(-i)], today.addDays(-i), today, habitStart),
  ];
}

double? _dayValue(OccurrenceStatus? status, CivilDate date, CivilDate today, CivilDate habitStart) {
  if (date.isBefore(habitStart) || date.isAfter(today)) return null;
  return switch (status) {
    OccurrenceStatus.completed => 1.0,
    OccurrenceStatus.missed => 0.0,
    // §8.5/§9.6: an active skip or a policy-driven cancellation is neutral,
    // not a mark against the day — same rule `_computeStats`'s streak uses.
    OccurrenceStatus.skipped || OccurrenceStatus.cancelled || OccurrenceStatus.pending || null => null,
  };
}

/// §13.2: "this month's completion percentage." `null` when the month has
/// no occurrences yet (a habit created today, for instance) rather than a
/// misleading `0%`.
double? computeMonthCompletionRate(List<AppOccurrence> occurrences, {required CivilDate today}) {
  final monthOccurrences = occurrences.where(
    (o) => o.scheduledDate.year == today.year && o.scheduledDate.month == today.month && o.scheduledDate.isAtOrBefore(today),
  );
  var done = 0;
  var total = 0;
  for (final occurrence in monthOccurrences) {
    if (occurrence.status == OccurrenceStatus.skipped || occurrence.status == OccurrenceStatus.cancelled) continue;
    total++;
    if (occurrence.status == OccurrenceStatus.completed) done++;
  }
  return total == 0 ? null : done / total;
}
