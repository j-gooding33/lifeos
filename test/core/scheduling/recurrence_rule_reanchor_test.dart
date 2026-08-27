import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/scheduling/recurrence_rule_reanchor.dart';

void main() {
  const oldAnchor = CivilDate(2026, 1, 1);
  const newAnchor = CivilDate(2026, 3, 15);
  const until = CivilDate(2026, 12, 31);

  test('IntervalDays keeps n, until, count; moves anchor', () {
    const rule = IntervalDays(5, anchor: oldAnchor, until: until, count: 10);
    final reanchored = reanchorRule(rule, newAnchor) as IntervalDays;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.n, 5);
    expect(reanchored.until, until);
    expect(reanchored.count, 10);
  });

  test('WeeklyDays keeps days and everyNWeeks; moves anchor', () {
    const rule = WeeklyDays(
      {Weekday.monday, Weekday.thursday},
      anchor: oldAnchor,
      everyNWeeks: 2,
    );
    final reanchored = reanchorRule(rule, newAnchor) as WeeklyDays;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.days, {Weekday.monday, Weekday.thursday});
    expect(reanchored.everyNWeeks, 2);
  });

  test('MonthlyDay keeps dayOfMonth and everyNMonths; moves anchor', () {
    const rule = MonthlyDay(31, anchor: oldAnchor, everyNMonths: 3);
    final reanchored = reanchorRule(rule, newAnchor) as MonthlyDay;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.dayOfMonth, 31);
    expect(reanchored.everyNMonths, 3);
  });

  test('MonthlyWeekday keeps nth, day and everyNMonths; moves anchor', () {
    const rule = MonthlyWeekday(-1, Weekday.friday, anchor: oldAnchor);
    final reanchored = reanchorRule(rule, newAnchor) as MonthlyWeekday;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.nth, -1);
    expect(reanchored.day, Weekday.friday);
  });

  test('Yearly keeps month, day and the leap-year flag; moves anchor', () {
    const rule = Yearly(
      2,
      29,
      anchor: oldAnchor,
      useMarchFirstOnNonLeapYears: true,
    );
    final reanchored = reanchorRule(rule, newAnchor) as Yearly;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.month, 2);
    expect(reanchored.day, 29);
    expect(reanchored.useMarchFirstOnNonLeapYears, isTrue);
  });

  test('CustomDates keeps the date list; moves anchor', () {
    const dates = [CivilDate(2026, 2, 1), CivilDate(2026, 2, 15)];
    const rule = CustomDates(dates, anchor: oldAnchor);
    final reanchored = reanchorRule(rule, newAnchor) as CustomDates;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.dates, dates);
  });

  test('TimesPerPeriod keeps times and period; moves anchor', () {
    const rule = TimesPerPeriod(3, Period.week, anchor: oldAnchor);
    final reanchored = reanchorRule(rule, newAnchor) as TimesPerPeriod;
    expect(reanchored.anchor, newAnchor);
    expect(reanchored.times, 3);
    expect(reanchored.period, Period.week);
  });
}
