import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/features/plans/application/habit_stats.dart';

AppOccurrence _occ(CivilDate date, OccurrenceStatus status) {
  return AppOccurrence(id: date.toIso(), planId: 'p1', scheduledDate: date, status: status);
}

void main() {
  const today = CivilDate(2026, 8, 27);

  group('computeYearHeatmap', () {
    test('has exactly 365 values ending today', () {
      final values = computeYearHeatmap(const [], today: today, habitStart: today.addDays(-400));
      expect(values, hasLength(365));
    });

    test('completed is 1.0, missed is 0.0', () {
      final values = computeYearHeatmap([
        _occ(today, OccurrenceStatus.completed),
        _occ(today.addDays(-1), OccurrenceStatus.missed),
      ], today: today, habitStart: today.addDays(-30));
      expect(values.last, 1.0);
      expect(values[values.length - 2], 0.0);
    });

    test('skipped, cancelled and pending are neutral (null), not a mark against the day', () {
      final values = computeYearHeatmap([
        _occ(today, OccurrenceStatus.skipped),
        _occ(today.addDays(-1), OccurrenceStatus.cancelled),
        _occ(today.addDays(-2), OccurrenceStatus.pending),
      ], today: today, habitStart: today.addDays(-30));
      expect(values.last, isNull);
      expect(values[values.length - 2], isNull);
      expect(values[values.length - 3], isNull);
    });

    test('days before the habit started are null even with no occurrence data', () {
      final habitStart = today.addDays(-5);
      final values = computeYearHeatmap(const [], today: today, habitStart: habitStart);
      // Everything before day 360 (365 - 5) should be null; the last 6 days (start..today) have no data either, so also null here.
      expect(values.every((v) => v == null), isTrue);
    });
  });

  group('computeMonthCompletionRate', () {
    test('is null when the month has no occurrences yet', () {
      expect(computeMonthCompletionRate(const [], today: today), isNull);
    });

    test('counts only this month, up to today, ignoring skipped/cancelled', () {
      final rate = computeMonthCompletionRate([
        _occ(const CivilDate(2026, 8, 1), OccurrenceStatus.completed),
        _occ(const CivilDate(2026, 8, 2), OccurrenceStatus.missed),
        _occ(const CivilDate(2026, 8, 3), OccurrenceStatus.skipped),
        _occ(const CivilDate(2026, 7, 31), OccurrenceStatus.completed), // last month
        _occ(const CivilDate(2026, 8, 28), OccurrenceStatus.completed), // after today
      ], today: today);
      expect(rate, 0.5); // 1 done out of 2 counted (skip excluded, future excluded, last month excluded)
    });
  });
}
