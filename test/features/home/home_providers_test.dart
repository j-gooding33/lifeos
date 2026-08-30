import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/features/home/application/home_providers.dart';

AppTask _task(String title, {String? dueDate}) {
  return AppTask(id: title, userId: 'u1', title: title, dueDate: dueDate);
}

AppOccurrence _occurrence(
  String id, {
  required String planId,
  required int day,
  OccurrenceStatus status = OccurrenceStatus.pending,
  String? linkedEntityType,
  String? linkedEntityId,
}) {
  return AppOccurrence(
    id: id,
    planId: planId,
    scheduledDate: CivilDate(2026, 9, day),
    status: status,
    linkedEntityType: linkedEntityType,
    linkedEntityId: linkedEntityId,
  );
}

void main() {
  test('groups dated tasks by day and undated tasks separately', () {
    final result = bucketUpcoming([
      _task('Dentist', dueDate: '2026-09-01'),
      _task('Gym', dueDate: '2026-09-01'),
      _task('Trip', dueDate: '2026-09-03'),
      _task('Read that book'),
      _task('Learn Spanish'),
    ]);

    expect(result.byDay['2026-09-01']!.count, 2);
    expect(result.byDay['2026-09-01']!.firstTitle, 'Dentist');
    expect(result.byDay['2026-09-03']!.count, 1);
    expect(result.byDay['2026-09-03']!.firstTitle, 'Trip');
    expect(result.undated.count, 2);
    expect(result.undated.firstTitle, 'Read that book');
  });

  test('empty input produces empty buckets, not a crash', () {
    final result = bucketUpcoming(const []);
    expect(result.byDay, isEmpty);
    expect(result.undated.isEmpty, isTrue);
    expect(result.undated.firstTitle, isNull);
  });

  test('HomeSnapshot.hasNothingUpcoming is true only when every bucket is empty', () {
    const empty = UpcomingBucket(count: 0, firstTitle: null);
    const full = UpcomingBucket(count: 1, firstTitle: 'Something');

    const allEmpty = HomeSnapshot(
      focusItems: [],
      doneToday: 0,
      totalToday: 0,
      upcomingByDay: {'2026-09-01': empty},
      upcomingUndated: empty,
      recent: [],
      plansToday: [],
      plansTodayTitles: {},
      habits: [],
      goals: [],
      projects: [],
      plansCompletedToday: 0,
      currentStreakDays: 0,
      journalWrittenToday: false,
      spentThisMonthMinor: 0,
      monthlyBudgetMinor: null,
      currency: 'GBP',
      filmNext: null,
    );
    const oneFull = HomeSnapshot(
      focusItems: [],
      doneToday: 0,
      totalToday: 0,
      upcomingByDay: {'2026-09-01': full},
      upcomingUndated: empty,
      recent: [],
      plansToday: [],
      plansTodayTitles: {},
      habits: [],
      goals: [],
      projects: [],
      plansCompletedToday: 0,
      currentStreakDays: 0,
      journalWrittenToday: false,
      spentThisMonthMinor: 0,
      monthlyBudgetMinor: null,
      currency: 'GBP',
      filmNext: null,
    );

    expect(allEmpty.hasNothingUpcoming, isTrue);
    expect(oneFull.hasNothingUpcoming, isFalse);
  });

  group('nextLinkedFilmOccurrence', () {
    test('picks the soonest linked occurrence among the given plan ids', () {
      final occurrences = [
        _occurrence('a', planId: 'film-plan', day: 8, linkedEntityType: 'libraryItem', linkedEntityId: 'item1'),
        _occurrence('b', planId: 'film-plan', day: 2, linkedEntityType: 'libraryItem', linkedEntityId: 'item2'),
        _occurrence('c', planId: 'film-plan', day: 5, linkedEntityType: 'libraryItem', linkedEntityId: 'item3'),
      ];
      final result = nextLinkedFilmOccurrence(occurrences, {'film-plan'});
      expect(result?.id, 'b');
    });

    test('ignores occurrences with nothing linked yet', () {
      final occurrences = [_occurrence('a', planId: 'film-plan', day: 2)];
      expect(nextLinkedFilmOccurrence(occurrences, {'film-plan'}), isNull);
    });

    test('ignores occurrences from plans not in the given set', () {
      final occurrences = [
        _occurrence('a', planId: 'other-plan', day: 2, linkedEntityType: 'libraryItem', linkedEntityId: 'item1'),
      ];
      expect(nextLinkedFilmOccurrence(occurrences, {'film-plan'}), isNull);
    });

    test('ignores completed or cancelled occurrences even if linked', () {
      final occurrences = [
        _occurrence(
          'a',
          planId: 'film-plan',
          day: 2,
          status: OccurrenceStatus.completed,
          linkedEntityType: 'libraryItem',
          linkedEntityId: 'item1',
        ),
        _occurrence(
          'b',
          planId: 'film-plan',
          day: 4,
          status: OccurrenceStatus.cancelled,
          linkedEntityType: 'libraryItem',
          linkedEntityId: 'item2',
        ),
      ];
      expect(nextLinkedFilmOccurrence(occurrences, {'film-plan'}), isNull);
    });

    test('empty input returns null, not a crash', () {
      expect(nextLinkedFilmOccurrence(const [], {'film-plan'}), isNull);
    });
  });

  group('currentStreak', () {
    const today = CivilDate(2026, 9, 5);

    test('counts consecutive active days ending today', () {
      final scores = {today: 2, today.addDays(-1): 1, today.addDays(-2): 3};
      expect(currentStreak(scores, today), 3);
    });

    test('stops at the first gap, even with active days further back', () {
      final scores = {today: 1, today.addDays(-2): 1};
      expect(currentStreak(scores, today), 1);
    });

    test('is zero when today itself has no activity', () {
      final scores = {today.addDays(-1): 4};
      expect(currentStreak(scores, today), 0);
    });
  });
}
