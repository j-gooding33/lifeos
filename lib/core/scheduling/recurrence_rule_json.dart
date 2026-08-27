import 'dart:convert';

import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';

/// §23.1: rules are stored as `TEXT JSON`. This is the one place that
/// shape is defined — everywhere else works with the typed
/// `RecurrenceRule` hierarchy.
extension RecurrenceRuleJson on RecurrenceRule {
  Map<String, dynamic> toJsonMap() {
    final base = {
      'anchor': anchor.toIso(),
      if (until != null) 'until': until!.toIso(),
      if (count != null) 'count': count,
    };
    final rule = this;
    return switch (rule) {
      IntervalDays() => {...base, 'type': 'intervalDays', 'n': rule.n},
      WeeklyDays() => {
        ...base,
        'type': 'weeklyDays',
        'days': rule.days.map((d) => d.isoValue).toList(),
        'everyNWeeks': rule.everyNWeeks,
      },
      MonthlyDay() => {
        ...base,
        'type': 'monthlyDay',
        'dayOfMonth': rule.dayOfMonth,
        'everyNMonths': rule.everyNMonths,
      },
      MonthlyWeekday() => {
        ...base,
        'type': 'monthlyWeekday',
        'nth': rule.nth,
        'day': rule.day.isoValue,
        'everyNMonths': rule.everyNMonths,
      },
      Yearly() => {
        ...base,
        'type': 'yearly',
        'month': rule.month,
        'day': rule.day,
        'useMarchFirstOnNonLeapYears': rule.useMarchFirstOnNonLeapYears,
      },
      CustomDates() => {
        ...base,
        'type': 'customDates',
        'dates': rule.dates.map((d) => d.toIso()).toList(),
      },
      TimesPerPeriod() => {
        ...base,
        'type': 'timesPerPeriod',
        'times': rule.times,
        'period': rule.period.name,
      },
    };
  }

  String toJsonString() => jsonEncode(toJsonMap());
}

RecurrenceRule recurrenceRuleFromJsonMap(Map<String, dynamic> json) {
  final anchor = CivilDate.parse(json['anchor'] as String);
  final until = json['until'] != null ? CivilDate.parse(json['until'] as String) : null;
  final count = json['count'] as int?;

  return switch (json['type']) {
    'intervalDays' => IntervalDays(json['n'] as int, anchor: anchor, until: until, count: count),
    'weeklyDays' => WeeklyDays(
      (json['days'] as List).map((v) => Weekday.fromIso(v as int)).toSet(),
      anchor: anchor,
      everyNWeeks: json['everyNWeeks'] as int? ?? 1,
      until: until,
      count: count,
    ),
    'monthlyDay' => MonthlyDay(
      json['dayOfMonth'] as int,
      anchor: anchor,
      everyNMonths: json['everyNMonths'] as int? ?? 1,
      until: until,
      count: count,
    ),
    'monthlyWeekday' => MonthlyWeekday(
      json['nth'] as int,
      Weekday.fromIso(json['day'] as int),
      anchor: anchor,
      everyNMonths: json['everyNMonths'] as int? ?? 1,
      until: until,
      count: count,
    ),
    'yearly' => Yearly(
      json['month'] as int,
      json['day'] as int,
      anchor: anchor,
      useMarchFirstOnNonLeapYears: json['useMarchFirstOnNonLeapYears'] as bool? ?? false,
      until: until,
      count: count,
    ),
    'customDates' => CustomDates(
      (json['dates'] as List).map((v) => CivilDate.parse(v as String)).toList(),
      anchor: anchor,
      until: until,
      count: count,
    ),
    'timesPerPeriod' => TimesPerPeriod(
      json['times'] as int,
      Period.values.byName(json['period'] as String),
      anchor: anchor,
      until: until,
      count: count,
    ),
    final type => throw FormatException('Unknown RecurrenceRule type: $type'),
  };
}

RecurrenceRule recurrenceRuleFromJsonString(String source) =>
    recurrenceRuleFromJsonMap(jsonDecode(source) as Map<String, dynamic>);
