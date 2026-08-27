import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart' show DateRange;
import 'package:life_os/core/school/school_week_engine.dart';

void main() {
  group('weekLabelFor', () {
    // Monday 2026-09-07, anchored as Week A.
    const anchor = CivilDate(2026, 9, 7);

    test('the anchor date itself is the anchor label', () {
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.a,
          date: anchor,
        ),
        WeekLabel.a,
      );
    });

    test(
      'a different weekday in the same calendar week is still the anchor label',
      () {
        final friday = anchor.addDays(4);
        expect(
          weekLabelFor(
            anchorDate: anchor,
            anchorLabel: WeekLabel.a,
            date: friday,
          ),
          WeekLabel.a,
        );
      },
    );

    test('the following week flips the label', () {
      final nextMonday = anchor.addDays(7);
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.a,
          date: nextMonday,
        ),
        WeekLabel.b,
      );
    });

    test('two weeks later returns to the anchor label', () {
      final twoWeeksLater = anchor.addDays(14);
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.a,
          date: twoWeeksLater,
        ),
        WeekLabel.a,
      );
    });

    test('the previous week flips the label', () {
      final previousMonday = anchor.addDays(-7);
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.a,
          date: previousMonday,
        ),
        WeekLabel.b,
      );
    });

    test('two weeks earlier returns to the anchor label', () {
      final twoWeeksEarlier = anchor.addDays(-14);
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.a,
          date: twoWeeksEarlier,
        ),
        WeekLabel.a,
      );
    });

    test('works across a year boundary', () {
      const decemberAnchor = CivilDate(2026, 12, 21); // a Monday
      final januaryMonday = decemberAnchor.addDays(21); // 3 weeks later
      expect(
        weekLabelFor(
          anchorDate: decemberAnchor,
          anchorLabel: WeekLabel.b,
          date: januaryMonday,
        ),
        WeekLabel.a,
      );
    });

    test('symmetric when the anchor label is B', () {
      final nextMonday = anchor.addDays(7);
      expect(
        weekLabelFor(
          anchorDate: anchor,
          anchorLabel: WeekLabel.b,
          date: nextMonday,
        ),
        WeekLabel.a,
      );
    });
  });

  group('isSchoolOpen', () {
    final autumnTerm = [
      const DateRange(CivilDate(2026, 9, 1), CivilDate(2026, 12, 19)),
    ];
    final halfTerm = [
      const DateRange(CivilDate(2026, 10, 26), CivilDate(2026, 10, 30)),
    ];

    test('a date inside the term with no closures is open', () {
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 9, 15),
          terms: autumnTerm,
          closures: halfTerm,
        ),
        isTrue,
      );
    });

    test('a date outside every term is closed, no closure entry needed', () {
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 7, 15),
          terms: autumnTerm,
          closures: const [],
        ),
        isFalse,
      );
    });

    test('a date inside a closure within the term is closed', () {
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 10, 28),
          terms: autumnTerm,
          closures: halfTerm,
        ),
        isFalse,
      );
    });

    test('term boundaries are inclusive', () {
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 9, 1),
          terms: autumnTerm,
          closures: const [],
        ),
        isTrue,
      );
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 12, 19),
          terms: autumnTerm,
          closures: const [],
        ),
        isTrue,
      );
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 12, 20),
          terms: autumnTerm,
          closures: const [],
        ),
        isFalse,
      );
    });

    test('closure boundaries are inclusive', () {
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 10, 26),
          terms: autumnTerm,
          closures: halfTerm,
        ),
        isFalse,
      );
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 10, 30),
          terms: autumnTerm,
          closures: halfTerm,
        ),
        isFalse,
      );
      expect(
        isSchoolOpen(
          date: const CivilDate(2026, 10, 31),
          terms: autumnTerm,
          closures: halfTerm,
        ),
        isTrue,
      );
    });
  });

  group('lessonsOnDate', () {
    const anchor = CivilDate(2026, 9, 7); // Monday, Week A
    const weekAMaths = SchoolLessonSlot(
      id: 'a-maths',
      weekLabel: 'A',
      weekday: 1,
      subject: 'Maths',
      startTime: '09:00',
      endTime: '10:00',
    );
    const weekAEnglish = SchoolLessonSlot(
      id: 'a-english',
      weekLabel: 'A',
      weekday: 1,
      subject: 'English',
      startTime: '10:00',
      endTime: '11:00',
    );
    const weekBHistory = SchoolLessonSlot(
      id: 'b-history',
      weekLabel: 'B',
      weekday: 1,
      subject: 'History',
      startTime: '09:00',
      endTime: '10:00',
    );
    const tuesdayLesson = SchoolLessonSlot(
      id: 'tuesday',
      weekLabel: 'A',
      weekday: 2,
      subject: 'Science',
      startTime: '09:00',
      endTime: '10:00',
    );
    final allLessons = [weekAEnglish, weekAMaths, weekBHistory, tuesdayLesson];

    test("a two-week timetable returns only the matching week's lessons, sorted by time", () {
      final result = lessonsOnDate(
        date: anchor,
        allLessons: allLessons,
        isTwoWeekTimetable: true,
        anchorDate: anchor,
        anchorLabel: WeekLabel.a,
      );
      expect(result.map((l) => l.id), ['a-maths', 'a-english']);
    });

    test("the alternating week returns the other week's lessons", () {
      final nextMonday = anchor.addDays(7);
      final result = lessonsOnDate(
        date: nextMonday,
        allLessons: allLessons,
        isTwoWeekTimetable: true,
        anchorDate: anchor,
        anchorLabel: WeekLabel.a,
      );
      expect(result.map((l) => l.id), ['b-history']);
    });

    test('a one-week timetable ignores weekLabel and matches every week', () {
      const allWeekLesson = SchoolLessonSlot(
        id: 'all-weeks',
        weekLabel: 'ALL',
        weekday: 1,
        subject: 'Form time',
        startTime: '08:30',
        endTime: '08:45',
      );
      final result = lessonsOnDate(
        date: anchor,
        allLessons: [allWeekLesson],
        isTwoWeekTimetable: false,
        anchorDate: anchor,
        anchorLabel: WeekLabel.a,
      );
      expect(result.map((l) => l.id), ['all-weeks']);
    });

    test('a weekday with no lessons returns an empty list', () {
      final wednesday = anchor.addDays(2);
      final result = lessonsOnDate(
        date: wednesday,
        allLessons: allLessons,
        isTwoWeekTimetable: true,
        anchorDate: anchor,
        anchorLabel: WeekLabel.a,
      );
      expect(result, isEmpty);
    });
  });
}
