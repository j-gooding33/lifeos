import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

/// §9.4 rolling mode: "the next date is `completedAt + n days`" generalises,
/// for every rule type, to "restart the rhythm's phase from [newAnchor]"
/// while keeping every other parameter (`until`/`count` included)
/// unchanged. A sibling to `recurrence_rule_json.dart` rather than a method
/// on `RecurrenceRule` itself, for the same reason: keep the tested M6-core
/// files untouched and add data/behaviour-layer concerns alongside them.
RecurrenceRule reanchorRule(RecurrenceRule rule, CivilDate newAnchor) {
  return switch (rule) {
    IntervalDays(:final n) => IntervalDays(
      n,
      anchor: newAnchor,
      until: rule.until,
      count: rule.count,
    ),
    WeeklyDays(:final days, :final everyNWeeks) => WeeklyDays(
      days,
      anchor: newAnchor,
      everyNWeeks: everyNWeeks,
      until: rule.until,
      count: rule.count,
    ),
    MonthlyDay(:final dayOfMonth, :final everyNMonths) => MonthlyDay(
      dayOfMonth,
      anchor: newAnchor,
      everyNMonths: everyNMonths,
      until: rule.until,
      count: rule.count,
    ),
    MonthlyWeekday(:final nth, :final day, :final everyNMonths) =>
      MonthlyWeekday(
        nth,
        day,
        anchor: newAnchor,
        everyNMonths: everyNMonths,
        until: rule.until,
        count: rule.count,
      ),
    Yearly(:final month, :final day, :final useMarchFirstOnNonLeapYears) =>
      Yearly(
        month,
        day,
        anchor: newAnchor,
        useMarchFirstOnNonLeapYears: useMarchFirstOnNonLeapYears,
        until: rule.until,
        count: rule.count,
      ),
    CustomDates(:final dates) => CustomDates(
      dates,
      anchor: newAnchor,
      until: rule.until,
      count: rule.count,
    ),
    TimesPerPeriod(:final times, :final period) => TimesPerPeriod(
      times,
      period,
      anchor: newAnchor,
      until: rule.until,
      count: rule.count,
    ),
  };
}
