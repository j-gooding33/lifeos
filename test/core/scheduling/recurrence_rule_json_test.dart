import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/scheduling/recurrence_rule_json.dart';

void main() {
  const engine = RecurrenceEngine();

  void expectRoundTrips(RecurrenceRule rule) {
    final decoded = recurrenceRuleFromJsonString(rule.toJsonString());
    final window = DateRange(rule.anchor, rule.anchor.addDays(60));
    expect(engine.datesIn(decoded, window), engine.datesIn(rule, window));
  }

  test('IntervalDays round-trips', () {
    expectRoundTrips(const IntervalDays(3, anchor: CivilDate(2026, 9, 1), count: 5));
  });

  test('WeeklyDays round-trips', () {
    expectRoundTrips(
      const WeeklyDays({Weekday.monday, Weekday.thursday}, anchor: CivilDate(2026, 9, 1), everyNWeeks: 2),
    );
  });

  test('MonthlyDay round-trips', () {
    expectRoundTrips(const MonthlyDay(-1, anchor: CivilDate(2026, 1, 31)));
  });

  test('MonthlyWeekday round-trips', () {
    expectRoundTrips(const MonthlyWeekday(-1, Weekday.friday, anchor: CivilDate(2026, 9, 25)));
  });

  test('Yearly round-trips', () {
    expectRoundTrips(const Yearly(2, 29, anchor: CivilDate(2028, 2, 29)));
  });

  test('CustomDates round-trips', () {
    expectRoundTrips(
      const CustomDates([
        CivilDate(2026, 9, 1),
        CivilDate(2026, 12, 25),
      ], anchor: CivilDate(2026, 9, 1)),
    );
  });

  test('TimesPerPeriod round-trips', () {
    expectRoundTrips(const TimesPerPeriod(3, Period.week, anchor: CivilDate(2026, 9, 1)));
  });
}
