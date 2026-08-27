import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

const _weekdayShort = {
  Weekday.monday: 'Mon',
  Weekday.tuesday: 'Tue',
  Weekday.wednesday: 'Wed',
  Weekday.thursday: 'Thu',
  Weekday.friday: 'Fri',
  Weekday.saturday: 'Sat',
  Weekday.sunday: 'Sun',
};

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _ordinals = {1: '1st', 2: '2nd', 3: '3rd', 4: '4th', -1: 'last'};

/// §7.4/§7.5: the rhythm rendered in `mono` (e.g. "every 3 days"), reused
/// by the Plans list row and the Plan detail header.
String describeRule(RecurrenceRule rule) {
  return switch (rule) {
    IntervalDays(n: 1) => 'Every day',
    IntervalDays(n: 2) => 'Every other day',
    IntervalDays(:final n) => 'Every $n days',
    WeeklyDays(:final days, :final everyNWeeks) => _describeWeekly(
      days,
      everyNWeeks,
    ),
    MonthlyDay(:final dayOfMonth, :final everyNMonths) => _describeMonthlyDay(
      dayOfMonth,
      everyNMonths,
    ),
    MonthlyWeekday(:final nth, :final day, :final everyNMonths) =>
      _describeMonthlyWeekday(nth, day, everyNMonths),
    Yearly(:final month, :final day) => 'Every ${_monthNames[month - 1]} $day',
    CustomDates() => 'Specific dates',
    TimesPerPeriod(:final times, :final period) =>
      '$times× a ${period == Period.week ? 'week' : 'month'}',
  };
}

String _describeWeekly(Set<Weekday> days, int everyNWeeks) {
  final sorted = days.toList()
    ..sort((a, b) => a.isoValue.compareTo(b.isoValue));
  final dayNames = sorted.map((d) => _weekdayShort[d]).join(', ');
  return everyNWeeks == 1 ? dayNames : 'Every $everyNWeeks weeks on $dayNames';
}

String _describeMonthlyDay(int dayOfMonth, int everyNMonths) {
  final dayLabel = dayOfMonth == -1
      ? 'last day'
      : 'the ${_ordinal(dayOfMonth)}';
  return everyNMonths == 1
      ? 'Monthly on $dayLabel'
      : 'Every $everyNMonths months on $dayLabel';
}

String _describeMonthlyWeekday(int nth, Weekday day, int everyNMonths) {
  final ordinal = _ordinals[nth] ?? '${nth}th';
  final label = 'the $ordinal ${_weekdayShort[day]}';
  return everyNMonths == 1
      ? 'Monthly on $label'
      : 'Every $everyNMonths months on $label';
}

String _ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}
