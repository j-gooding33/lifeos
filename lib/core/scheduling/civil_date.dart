import 'package:meta/meta.dart';

/// A date with no time and no zone (§9.1) — `2026-09-01`. Used for every
/// occurrence date, task due date, journal date, and stat bucket. Never
/// use `DateTime` for these: `DateTime` arithmetic crosses DST boundaries
/// and silently produces 23-/25-hour days, which is exactly how "every 3
/// days" drifts near a DST transition. All arithmetic here is done by
/// converting to a Julian day number and adding/subtracting integers,
/// which is DST-proof by construction.
@immutable
class CivilDate implements Comparable<CivilDate> {
  const CivilDate(this.year, this.month, this.day);

  factory CivilDate.parse(String value) {
    final parts = value.split('-');
    return CivilDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  factory CivilDate.fromDateTime(DateTime dateTime) =>
      CivilDate(dateTime.year, dateTime.month, dateTime.day);

  factory CivilDate.fromJulianDayNumber(int jdn) {
    // Binary-search-free reconstruction: walk forward year by year from a
    // safe lower bound. Golden case 19 (10-year window, <20ms) means this
    // must stay cheap — it's O(1) amortised since we start near the target.
    var year = (jdn / 365.2425).floor() - 1;
    while (CivilDate(year + 1, 1, 1).toJulianDayNumber() <= jdn) {
      year++;
    }
    while (CivilDate(year, 1, 1).toJulianDayNumber() > jdn) {
      year--;
    }
    var month = 1;
    while (month < 12 && CivilDate(year, month + 1, 1).toJulianDayNumber() <= jdn) {
      month++;
    }
    final day = jdn - CivilDate(year, month, 1).toJulianDayNumber() + 1;
    return CivilDate(year, month, day);
  }

  final int year;
  final int month;
  final int day;

  static const _cumulativeDays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) return 29;
    return days[month - 1];
  }

  static int daysBetween(CivilDate from, CivilDate to) =>
      to.toJulianDayNumber() - from.toJulianDayNumber();

  static int monthsBetween(CivilDate from, CivilDate to) =>
      (to.year * 12 + to.month) - (from.year * 12 + from.month);

  static int _leapDaysBefore(int year) {
    final y = year - 1;
    return (y ~/ 4) - (y ~/ 100) + (y ~/ 400);
  }

  /// A monotonically increasing day number (not a true Julian Day Number,
  /// just an internal linear count — the only property that matters is
  /// that consecutive calendar days differ by exactly 1).
  int toJulianDayNumber() {
    var days = year * 365 + _leapDaysBefore(year);
    days += _cumulativeDays[month - 1];
    if (month > 2 && isLeapYear(year)) days += 1;
    return days + day;
  }

  CivilDate addDays(int days) => CivilDate.fromJulianDayNumber(toJulianDayNumber() + days);

  CivilDate addMonths(int months) {
    final totalMonths = (year * 12 + (month - 1)) + months;
    final newYear = totalMonths ~/ 12;
    final newMonth = totalMonths % 12 + 1;
    final clampedDay = day.clamp(1, daysInMonth(newYear, newMonth));
    return CivilDate(newYear, newMonth, clampedDay);
  }

  /// ISO weekday: Monday = 1 .. Sunday = 7.
  int get isoWeekday {
    // 2001-01-01 was a Monday; use it as a stable reference point.
    final ref = const CivilDate(2001, 1, 1).toJulianDayNumber();
    final diff = toJulianDayNumber() - ref;
    return ((diff % 7) + 7) % 7 + 1;
  }

  /// The Monday or Sunday (per `weekStartsMonday`) on/before this date.
  CivilDate startOfWeek({bool weekStartsMonday = true}) {
    final weekday = isoWeekday; // 1..7, Mon..Sun
    final sundayBasedIndex = weekday % 7; // Sun=0..Sat=6
    final offset = weekStartsMonday ? (weekday - 1) : sundayBasedIndex;
    return addDays(-offset);
  }

  bool get isLastDayOfMonth => day == daysInMonth(year, month);

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CivilDate other) => toJulianDayNumber().compareTo(other.toJulianDayNumber());

  bool isBefore(CivilDate other) => compareTo(other) < 0;
  bool isAfter(CivilDate other) => compareTo(other) > 0;
  bool isAtOrBefore(CivilDate other) => compareTo(other) <= 0;
  bool isAtOrAfter(CivilDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is CivilDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Matches `CivilDate.isoWeekday` (Monday = 1).
  int get isoValue => index + 1;

  static Weekday fromIso(int isoValue) => Weekday.values[isoValue - 1];
}
