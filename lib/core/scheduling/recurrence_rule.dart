import 'package:life_os/core/scheduling/civil_date.dart';

enum Period { week, month }

/// §9.2. `anchor` is the date the rhythm counts from; `until`/`count` are
/// alternative, optional end conditions.
sealed class RecurrenceRule {
  const RecurrenceRule({required this.anchor, this.until, this.count});

  final CivilDate anchor;
  final CivilDate? until;
  final int? count;
}

/// "Every n days." §9.3: `fires(d) ⟺ daysBetween(anchor,d) >= 0 &&
/// daysBetween(anchor,d) % n == 0`.
class IntervalDays extends RecurrenceRule {
  const IntervalDays(this.n, {required super.anchor, super.until, super.count});
  final int n;
}

/// Specific weekdays, every N weeks. Week start comes from the caller
/// (settings), never hard-coded (§9.3).
class WeeklyDays extends RecurrenceRule {
  const WeeklyDays(
    this.days, {
    required super.anchor,
    this.everyNWeeks = 1,
    super.until,
    super.count,
  });
  final Set<Weekday> days;
  final int everyNWeeks;
}

/// A fixed day of the month, or -1 for "the last day" (§9.3's clamping
/// rule for shorter months).
class MonthlyDay extends RecurrenceRule {
  const MonthlyDay(
    this.dayOfMonth, {
    required super.anchor,
    this.everyNMonths = 1,
    super.until,
    super.count,
  });
  final int dayOfMonth;
  final int everyNMonths;
}

/// The nth occurrence of a weekday in the month (1..4, or -1 for last). If
/// the nth doesn't exist that month (e.g. a 5th Tuesday), it simply
/// doesn't fire — no fallback (§9.3, unlike `MonthlyDay`'s clamping).
class MonthlyWeekday extends RecurrenceRule {
  const MonthlyWeekday(
    this.nth,
    this.day, {
    required super.anchor,
    this.everyNMonths = 1,
    super.until,
    super.count,
  });
  final int nth;
  final Weekday day;
  final int everyNMonths;
}

/// §9.3: 29 Feb anchors fire on 28 Feb in non-leap years by default;
/// `useMarchFirstOnNonLeapYears` flips that to 1 March per the settings
/// toggle the spec calls for.
class Yearly extends RecurrenceRule {
  const Yearly(
    this.month,
    this.day, {
    required super.anchor,
    this.useMarchFirstOnNonLeapYears = false,
    super.until,
    super.count,
  });
  final int month;
  final int day;
  final bool useMarchFirstOnNonLeapYears;
}

class CustomDates extends RecurrenceRule {
  const CustomDates(this.dates, {required super.anchor, super.until, super.count});
  final List<CivilDate> dates;
}

/// "3 times a week, any days" (§9.2) — the flexible rule. It does not pin
/// dates; `RecurrenceEngine` treats it specially (§9.2: "one occurrence
/// per period with remainingInPeriod, not N dated rows").
class TimesPerPeriod extends RecurrenceRule {
  const TimesPerPeriod(
    this.times,
    this.period, {
    required super.anchor,
    super.until,
    super.count,
  });
  final int times;
  final Period period;
}
