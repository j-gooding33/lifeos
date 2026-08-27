import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart' show DateRange;

/// M8 Part 30-32. Pure Dart, zero Flutter imports — same discipline as
/// `core/scheduling` (§9), because "which real-world Mondays are Week A"
/// is exactly the kind of date arithmetic that's easy to get subtly wrong
/// and expensive to get wrong silently.
enum WeekLabel { a, b }

/// A lesson slot as the engine sees it — not the Drift row type, so this
/// file stays free of any database dependency.
class SchoolLessonSlot {
  const SchoolLessonSlot({
    required this.id,
    required this.weekLabel,
    required this.weekday,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.teacher,
    this.room,
    this.colour,
  });

  final String id;

  /// `A` | `B` for a two-week timetable, `ALL` for a one-week one.
  final String weekLabel;

  /// ISO weekday, Monday = 1.
  final int weekday;
  final String subject;
  final String? teacher;
  final String? room;

  /// Wall time `HH:mm` (§9.1).
  final String startTime;
  final String endTime;
  final String? colour;
}

/// Every calendar week alternates A/B from [anchorDate]/[anchorLabel],
/// regardless of closures — closures are a separate "is school even open"
/// question (see [isSchoolOpen]). If a holiday breaks the alternation in a
/// way a school announces explicitly rather than lets fall out of pure
/// week-counting, the fix is re-anchoring `SchoolProfile`, not teaching
/// this function to guess holiday-specific conventions.
WeekLabel weekLabelFor({
  required CivilDate anchorDate,
  required WeekLabel anchorLabel,
  required CivilDate date,
  bool weekStartsMonday = true,
}) {
  final anchorWeekStart = anchorDate.startOfWeek(
    weekStartsMonday: weekStartsMonday,
  );
  final targetWeekStart = date.startOfWeek(weekStartsMonday: weekStartsMonday);
  final weeksDiff =
      CivilDate.daysBetween(anchorWeekStart, targetWeekStart) ~/ 7;
  final sameParity = weeksDiff.isEven;
  if (sameParity) return anchorLabel;
  return anchorLabel == WeekLabel.a ? WeekLabel.b : WeekLabel.a;
}

/// §33: school is only in session on a date covered by a term, and not
/// covered by a closure (half-term, inset day, a holiday between terms).
/// A date outside every term is a non-school day with no closure row
/// needed — most of the summer holiday, for instance.
bool isSchoolOpen({
  required CivilDate date,
  required List<DateRange> terms,
  required List<DateRange> closures,
}) {
  final inTerm = terms.any(
    (t) => date.isAtOrAfter(t.start) && date.isAtOrBefore(t.end),
  );
  if (!inTerm) return false;
  final closed = closures.any(
    (c) => date.isAtOrAfter(c.start) && date.isAtOrBefore(c.end),
  );
  return !closed;
}

/// The lessons that actually apply on [date]: matching weekday, and
/// matching the computed week label unless the timetable is `oneWeek`
/// (every lesson's `weekLabel` is `ALL` and matches every week). Returns
/// nothing if [isSchoolOpen] would say the date is closed — callers should
/// still check that themselves when they need to say *why* a day is empty
/// (closure vs. simply no lessons that period).
List<SchoolLessonSlot> lessonsOnDate({
  required CivilDate date,
  required List<SchoolLessonSlot> allLessons,
  required bool isTwoWeekTimetable,
  required CivilDate anchorDate,
  required WeekLabel anchorLabel,
}) {
  final weekday = date.isoWeekday;
  final label = isTwoWeekTimetable
      ? weekLabelFor(
          anchorDate: anchorDate,
          anchorLabel: anchorLabel,
          date: date,
        )
      : null;
  final matches = allLessons.where((lesson) {
    if (lesson.weekday != weekday) return false;
    if (!isTwoWeekTimetable) return true;
    return lesson.weekLabel == (label == WeekLabel.a ? 'A' : 'B');
  }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  return matches;
}
