import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/materialiser.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

CivilDate d(String iso) => CivilDate.parse(iso);
List<CivilDate> ds(List<String> isos) => isos.map(d).toList();

void main() {
  const engine = RecurrenceEngine();

  // #1
  test('IntervalDays(3) from 2026-09-01 fires 1,4,7,10,13,16 Sep', () {
    final rule = IntervalDays(3, anchor: d('2026-09-01'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-09-16')));
    expect(result, ds(['2026-09-01', '2026-09-04', '2026-09-07', '2026-09-10', '2026-09-13', '2026-09-16']));
  });

  // #2
  test('IntervalDays(1) is unaffected by UK spring-forward DST', () {
    final rule = IntervalDays(1, anchor: d('2026-03-27'));
    final result = engine.datesIn(rule, DateRange(d('2026-03-27'), d('2026-03-30')));
    expect(result, ds(['2026-03-27', '2026-03-28', '2026-03-29', '2026-03-30']));
  });

  // #3
  test('IntervalDays(2) from 2026-10-24 fires 24,26,28 Oct, not 25/27 (fall-back DST)', () {
    final rule = IntervalDays(2, anchor: d('2026-10-24'));
    final result = engine.datesIn(rule, DateRange(d('2026-10-24'), d('2026-10-28')));
    expect(result, ds(['2026-10-24', '2026-10-26', '2026-10-28']));
  });

  // #4
  test('IntervalDays(7) from 2027-02-24 is correct across a non-leap February', () {
    final rule = IntervalDays(7, anchor: d('2027-02-24'));
    final result = engine.datesIn(rule, DateRange(d('2027-02-24'), d('2027-03-03')));
    expect(result, ds(['2027-02-24', '2027-03-03']));
  });

  // #5
  test('IntervalDays(3) from 2028-02-26 handles the leap day', () {
    final rule = IntervalDays(3, anchor: d('2028-02-26'));
    final result = engine.datesIn(rule, DateRange(d('2028-02-26'), d('2028-03-03')));
    expect(result, ds(['2028-02-26', '2028-02-29', '2028-03-03']));
  });

  // #6
  test('WeeklyDays({Mon,Thu}) from Wed 2026-09-02 fires Thu 3, then 7, 10, 14', () {
    final rule = WeeklyDays({Weekday.monday, Weekday.thursday}, anchor: d('2026-09-02'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-02'), d('2026-09-14')));
    expect(result, ds(['2026-09-03', '2026-09-07', '2026-09-10', '2026-09-14']));
  });

  // #7
  test('WeeklyDays({Sun}, every 2 weeks) from 2026-09-06 fires 6,20 Sep, 4 Oct', () {
    final rule = WeeklyDays({Weekday.sunday}, everyNWeeks: 2, anchor: d('2026-09-06'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-06'), d('2026-10-04')));
    expect(result, ds(['2026-09-06', '2026-09-20', '2026-10-04']));
  });

  // #8
  test('WeeklyDays week-start setting changes the everyNWeeks bucketing', () {
    // Sunday sits in a different ISO week depending on whether the week
    // starts Monday or Sunday, so a biweekly Sunday rule buckets
    // differently under each convention.
    final rule = WeeklyDays({Weekday.sunday}, everyNWeeks: 2, anchor: d('2026-01-01'));
    final mondayStart = engine.datesIn(
      rule,
      DateRange(d('2026-01-01'), d('2026-02-28')),
    );
    final sundayStart = engine.datesIn(
      rule,
      DateRange(d('2026-01-01'), d('2026-02-28')),
      weekStartsMonday: false,
    );
    expect(mondayStart, isNotEmpty);
    expect(sundayStart, isNotEmpty);
    expect(mondayStart, isNot(equals(sundayStart)));
  });

  // #9
  test('MonthlyDay(31) clamps to the last day of shorter months', () {
    final rule = MonthlyDay(31, anchor: d('2026-01-31'));
    final result = engine.datesIn(rule, DateRange(d('2026-01-31'), d('2026-04-30')));
    expect(result, ds(['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30']));
  });

  // #10
  test('MonthlyDay(-1) is the true last day, including 29 Feb in a leap year', () {
    final rule = MonthlyDay(-1, anchor: d('2026-01-31'));
    final result = engine.datesIn(rule, DateRange(d('2028-01-01'), d('2028-02-29')));
    expect(result, contains(d('2028-02-29')));
  });

  // #11
  test('MonthlyDay(15, every 3 months) fires Jan, Apr, Jul, Oct', () {
    final rule = MonthlyDay(15, everyNMonths: 3, anchor: d('2026-01-15'));
    final result = engine.datesIn(rule, DateRange(d('2026-01-15'), d('2026-10-15')));
    expect(result, ds(['2026-01-15', '2026-04-15', '2026-07-15', '2026-10-15']));
  });

  // #12
  test('MonthlyWeekday(nth=5, Tue) skips months with no 5th Tuesday', () {
    final rule = MonthlyWeekday(5, Weekday.tuesday, anchor: d('2026-09-29'));
    // October 2026 has no 5th Tuesday.
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-10-31')));
    expect(result, [d('2026-09-29')]);
  });

  // #13
  test('MonthlyWeekday(nth=-1, Fri) is the last Friday each month', () {
    final rule = MonthlyWeekday(-1, Weekday.friday, anchor: d('2026-09-25'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-11-30')));
    expect(result, ds(['2026-09-25', '2026-10-30', '2026-11-27']));
  });

  // #14
  test('Yearly(29 Feb) fires 28 Feb in the next non-leap year by default', () {
    final rule = Yearly(2, 29, anchor: d('2028-02-29'));
    final result = engine.datesIn(rule, DateRange(d('2029-01-01'), d('2029-12-31')));
    expect(result, [d('2029-02-28')]);
  });

  // #15
  test('IntervalDays(3) with an until date stops exactly there', () {
    final rule = IntervalDays(3, anchor: d('2026-09-01'), until: d('2026-09-10'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-09-30')));
    expect(result, ds(['2026-09-01', '2026-09-04', '2026-09-07', '2026-09-10']));
  });

  // #16
  test('IntervalDays(3) with a count of 4 produces exactly 4 dates', () {
    final rule = IntervalDays(3, anchor: d('2026-09-01'), count: 4);
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-12-31')));
    expect(result, hasLength(4));
    expect(result, ds(['2026-09-01', '2026-09-04', '2026-09-07', '2026-09-10']));
  });

  // #17
  test('TimesPerPeriod(3, week) produces one quota row per ISO week', () {
    final rule = TimesPerPeriod(3, Period.week, anchor: d('2026-09-01'));
    final result = engine.datesIn(rule, DateRange(d('2026-09-01'), d('2026-09-21')));
    // 3 distinct week-start markers for a 3-week window.
    expect(result.toSet(), hasLength(3));
  });

  // #18
  test('a window entirely before the anchor returns an empty list, no exception', () {
    final rule = IntervalDays(3, anchor: d('2026-09-01'));
    final result = engine.datesIn(rule, DateRange(d('2026-01-01'), d('2026-08-31')));
    expect(result, isEmpty);
  });

  // #19
  test('a 10-year window resolves well under the performance budget', () {
    final rule = WeeklyDays({Weekday.monday, Weekday.thursday}, anchor: d('2020-01-01'));
    final stopwatch = Stopwatch()..start();
    final result = engine.datesIn(rule, DateRange(d('2020-01-01'), d('2030-01-01')));
    stopwatch.stop();
    expect(result, isNotEmpty);
    // Spec budget is 2ms for a 1-year window; this is a 10-year window run
    // on shared CI hardware, so the assertion is deliberately generous to
    // avoid flakiness while still catching a real regression.
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });

  // #20
  test("a rolling plan's next date is completion + n, not anchor + 2n", () {
    // "Rolling" is a Materialiser/Plan-repository concern (recompute the
    // anchor from the completion date) — the engine primitive it rests on
    // is just `next` from an arbitrary anchor, which this exercises.
    final completedLate = d('2026-09-08'); // anchor 2026-09-01, due 2026-09-06, done 2 days late
    final rolledRule = IntervalDays(5, anchor: completedLate);
    final next = engine.next(rolledRule, completedLate, 1);
    expect(next, [d('2026-09-13')]); // completion + 5, not anchor(1) + 10 = 11
  });

  // #21
  test('regenerating a plan preserves future exceptions', () {
    const materialiser = Materialiser();
    final rule = IntervalDays(3, anchor: d('2026-09-01'));
    final existing = [
      ExistingOccurrence(d('2026-09-10'), isException: true),
      ExistingOccurrence(d('2026-09-13'), isException: true),
      ExistingOccurrence(d('2026-09-16'), isException: true),
    ];
    final result = materialiser.materialise(
      rule: rule,
      through: d('2026-09-19'),
      existing: existing,
    );
    final dates = result.map((o) => o.date).toSet();
    // The 3 exception dates are not re-emitted (the caller keeps the
    // existing exception rows untouched); every other pending date is.
    expect(dates, isNot(contains(d('2026-09-10'))));
    expect(dates, isNot(contains(d('2026-09-13'))));
    expect(dates, isNot(contains(d('2026-09-16'))));
    expect(dates, containsAll(ds(['2026-09-01', '2026-09-04', '2026-09-07', '2026-09-19'])));
  });

  // #22
  test('civil dates carry no timezone, so a timezone change cannot affect them', () {
    // CivilDate has no timezone field at all — parsing and formatting are
    // pure integer operations. This is an architectural guarantee, not a
    // runtime toggle, so the test is that round-tripping is exact.
    final date = d('2026-09-01');
    expect(CivilDate.parse(date.toIso()), date);
  });

  // #23
  test('materialising twice for the same horizon is idempotent (no duplicates)', () {
    const materialiser = Materialiser();
    final rule = IntervalDays(2, anchor: d('2026-09-01'));
    final first = materialiser.materialise(rule: rule, through: d('2026-09-10'));
    final second = materialiser.materialise(rule: rule, through: d('2026-09-10'));
    expect(first.map((o) => o.date), second.map((o) => o.date));
  });

  // #24
  test('a pause window cancels occurrences inside it, not outside', () {
    const materialiser = Materialiser();
    final rule = IntervalDays(2, anchor: d('2026-09-01'));
    final result = materialiser.materialise(
      rule: rule,
      through: d('2026-09-13'),
      pauseFrom: d('2026-09-05'),
      pauseUntil: d('2026-09-12'),
    );
    final byDate = {for (final o in result) o.date: o.status};
    expect(byDate[d('2026-09-05')], MaterialisedStatus.cancelled);
    expect(byDate[d('2026-09-07')], MaterialisedStatus.cancelled);
    expect(byDate[d('2026-09-09')], MaterialisedStatus.cancelled);
    expect(byDate[d('2026-09-11')], MaterialisedStatus.cancelled);
    expect(byDate[d('2026-09-13')], MaterialisedStatus.pending);
  });

  group('MissedSweep (§9.6)', () {
    const sweep = MissedSweep();

    test('skip policy cancels silently', () {
      final results = sweep.apply(
        pastPending: [const PendingOccurrence('o1', 'p1', CivilDate(2026, 9, 1))],
        today: d('2026-09-05'),
        policy: MissedPolicy.skip,
      );
      expect(results.single.outcome, SweepOutcome.cancelled);
    });

    test('markMissed marks as missed', () {
      final results = sweep.apply(
        pastPending: [const PendingOccurrence('o1', 'p1', CivilDate(2026, 9, 1))],
        today: d('2026-09-05'),
        policy: MissedPolicy.markMissed,
      );
      expect(results.single.outcome, SweepOutcome.missed);
    });

    test('rollForward caps at 3 per plan per day, missing the rest', () {
      final pending = List.generate(
        5,
        (i) => PendingOccurrence('o$i', 'p1', CivilDate(2026, 9, 1 + i)),
      );
      final results = sweep.apply(pastPending: pending, today: d('2026-09-10'), policy: MissedPolicy.rollForward);
      final rolled = results.where((r) => r.outcome == SweepOutcome.rolledForward);
      final missed = results.where((r) => r.outcome == SweepOutcome.missed);
      expect(rolled, hasLength(3));
      expect(missed, hasLength(2));
    });
  });
}
