import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

class DateRange {
  const DateRange(this.start, this.end);
  final CivilDate start;
  final CivilDate end;
}

/// §9: the highest-risk component in the app. Pure Dart, zero Flutter
/// imports — see the golden test table at §9.9, mirrored exactly in
/// `test/core/scheduling/recurrence_engine_test.dart`.
///
/// Settings that affect calculation (week start, the 29 Feb toggle) are
/// parameters on each call, never hard-coded (§9.3) — the caller reads
/// them from the user's preferences.
class RecurrenceEngine {
  const RecurrenceEngine();

  List<CivilDate> datesIn(
    RecurrenceRule rule,
    DateRange window, {
    bool weekStartsMonday = true,
  }) {
    if (rule is TimesPerPeriod) {
      return _periodStartsIn(rule, window, weekStartsMonday: weekStartsMonday);
    }
    if (window.end.isBefore(window.start)) return const [];
    final dates = <CivilDate>[];
    var cursor = window.start;
    while (cursor.isAtOrBefore(window.end)) {
      if (firesOn(rule, cursor, weekStartsMonday: weekStartsMonday)) {
        dates.add(cursor);
      }
      cursor = cursor.addDays(1);
    }
    return dates;
  }

  List<CivilDate> next(RecurrenceRule rule, CivilDate after, int count, {bool weekStartsMonday = true}) {
    final dates = <CivilDate>[];
    var cursor = after.addDays(1);
    // A generous but bounded search window so a rule that can never fire
    // again (e.g. past its `until`) doesn't loop forever.
    var daysScanned = 0;
    const maxScan = 366 * 50;
    while (dates.length < count && daysScanned < maxScan) {
      if (firesOn(rule, cursor, weekStartsMonday: weekStartsMonday)) {
        dates.add(cursor);
      }
      cursor = cursor.addDays(1);
      daysScanned++;
    }
    return dates;
  }

  bool firesOn(RecurrenceRule rule, CivilDate date, {bool weekStartsMonday = true}) {
    if (date.isBefore(rule.anchor)) return false;
    if (rule.until != null && date.isAfter(rule.until!)) return false;

    final fires = switch (rule) {
      IntervalDays() => _intervalDaysFires(rule, date),
      WeeklyDays() => _weeklyDaysFires(rule, date, weekStartsMonday),
      MonthlyDay() => _monthlyDayFires(rule, date),
      MonthlyWeekday() => _monthlyWeekdayFires(rule, date),
      Yearly() => _yearlyFires(rule, date),
      CustomDates() => rule.dates.contains(date),
      TimesPerPeriod() => false, // doesn't pin individual dates — §9.2
    };
    if (!fires) return false;

    if (rule.count != null) {
      final ordinal = _ordinalIndex(rule, date, weekStartsMonday);
      if (ordinal == null || ordinal >= rule.count!) return false;
    }
    return true;
  }

  bool _intervalDaysFires(IntervalDays rule, CivilDate date) {
    final delta = CivilDate.daysBetween(rule.anchor, date);
    return delta % rule.n == 0;
  }

  bool _weeklyDaysFires(WeeklyDays rule, CivilDate date, bool weekStartsMonday) {
    if (!rule.days.contains(Weekday.fromIso(date.isoWeekday))) return false;
    final anchorWeekStart = rule.anchor.startOfWeek(weekStartsMonday: weekStartsMonday);
    final dateWeekStart = date.startOfWeek(weekStartsMonday: weekStartsMonday);
    final weekIndex = CivilDate.daysBetween(anchorWeekStart, dateWeekStart) ~/ 7;
    if (weekIndex < 0) return false;
    return weekIndex % rule.everyNWeeks == 0;
  }

  int _clampDayToMonth(int dayOfMonth, int year, int month) {
    if (dayOfMonth == -1) return CivilDate.daysInMonth(year, month);
    return dayOfMonth.clamp(1, CivilDate.daysInMonth(year, month));
  }

  bool _monthlyDayFires(MonthlyDay rule, CivilDate date) {
    final months = CivilDate.monthsBetween(rule.anchor, date);
    if (months < 0 || months % rule.everyNMonths != 0) return false;
    return date.day == _clampDayToMonth(rule.dayOfMonth, date.year, date.month);
  }

  CivilDate? _nthWeekdayOfMonth(int year, int month, int nth, Weekday weekday) {
    if (nth == -1) {
      var candidate = CivilDate(year, month, CivilDate.daysInMonth(year, month));
      while (candidate.isoWeekday != weekday.isoValue) {
        candidate = candidate.addDays(-1);
      }
      return candidate;
    }
    var candidate = CivilDate(year, month, 1);
    while (candidate.isoWeekday != weekday.isoValue) {
      candidate = candidate.addDays(1);
    }
    candidate = candidate.addDays((nth - 1) * 7);
    if (candidate.month != month) return null; // that nth doesn't exist this month
    return candidate;
  }

  bool _monthlyWeekdayFires(MonthlyWeekday rule, CivilDate date) {
    final months = CivilDate.monthsBetween(rule.anchor, date);
    if (months < 0 || months % rule.everyNMonths != 0) return false;
    final target = _nthWeekdayOfMonth(date.year, date.month, rule.nth, rule.day);
    return target == date;
  }

  bool _yearlyFires(Yearly rule, CivilDate date) {
    if (rule.month == 2 && rule.day == 29 && !CivilDate.isLeapYear(date.year)) {
      final fallback = rule.useMarchFirstOnNonLeapYears ? const (3, 1) : const (2, 28);
      return date.month == fallback.$1 && date.day == fallback.$2;
    }
    return date.month == rule.month && date.day == rule.day;
  }

  /// 0-based occurrence index from anchor, used to enforce `count`. Closed
  /// form for the rules that have one; bounded iteration otherwise (fine
  /// since `count`-limited rules are, definitionally, short-lived).
  int? _ordinalIndex(RecurrenceRule rule, CivilDate date, bool weekStartsMonday) {
    if (rule is IntervalDays) {
      return CivilDate.daysBetween(rule.anchor, date) ~/ rule.n;
    }
    var index = 0;
    var cursor = rule.anchor;
    while (cursor.isBefore(date)) {
      if (firesOn(rule, cursor, weekStartsMonday: weekStartsMonday)) index++;
      cursor = cursor.addDays(1);
    }
    return index;
  }

  List<CivilDate> _periodStartsIn(
    TimesPerPeriod rule,
    DateRange window, {
    required bool weekStartsMonday,
  }) {
    final starts = <CivilDate>[];
    var cursor = rule.period == Period.week
        ? window.start.startOfWeek(weekStartsMonday: weekStartsMonday)
        : CivilDate(window.start.year, window.start.month, 1);
    while (cursor.isAtOrBefore(window.end)) {
      if (cursor.isAtOrAfter(rule.anchor) && !starts.contains(cursor)) {
        starts.add(cursor);
      }
      cursor = rule.period == Period.week ? cursor.addDays(7) : cursor.addMonths(1);
    }
    return starts;
  }
}
