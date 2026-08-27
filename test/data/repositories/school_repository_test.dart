import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/school/school_week_engine.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/school_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:life_os/data/repositories/school_repository.dart';

void main() {
  late AppDatabase database;
  late SchoolRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SchoolRepository(SchoolDao(database));
  });

  tearDown(() => database.close());

  test('saveProfile then watchProfile round-trips a two-week timetable', () async {
    await repository.saveProfile(
      const AppSchoolProfile(
        userId: 'u1',
        schoolName: 'Riverside Academy',
        dayStartTime: '09:00',
        dayEndTime: '15:30',
        anchorDate: '2026-01-05',
      ),
    );

    final profile = await repository.watchProfile('u1').first;
    expect(profile, isNotNull);
    expect(profile!.schoolName, 'Riverside Academy');
    expect(profile.isTwoWeek, isTrue);
    expect(profile.anchorWeekLabel, WeekLabel.a);
  });

  test('watchProfile is null before any profile has been saved', () async {
    expect(await repository.watchProfile('u1').first, isNull);
  });

  test('saveLesson then watchLessons round-trips, and deleteLesson removes it', () async {
    final saved = await repository.saveLesson(
      userId: 'u1',
      weekLabel: 'A',
      weekday: 1,
      subject: 'Maths',
      startTime: '09:00',
      endTime: '10:00',
      teacher: 'Mx Lee',
    );
    expect(saved.isOk, isTrue);
    final lesson = (saved as Ok<AppSchoolLesson, Failure>).value;

    var lessons = await repository.watchLessons('u1').first;
    expect(lessons, hasLength(1));
    expect(lessons.single.subject, 'Maths');

    await repository.deleteLesson(lesson.id);
    lessons = await repository.watchLessons('u1').first;
    expect(lessons, isEmpty);
  });

  test('lessonsFor returns only same-weekday, same-week-label lessons for a two-week timetable', () async {
    const profile = AppSchoolProfile(userId: 'u1', anchorDate: '2026-01-05'); // a Monday, Week A
    await repository.saveLesson(userId: 'u1', weekLabel: 'A', weekday: 1, subject: 'Maths', startTime: '09:00', endTime: '10:00');
    await repository.saveLesson(userId: 'u1', weekLabel: 'B', weekday: 1, subject: 'Art', startTime: '09:00', endTime: '10:00');
    await repository.saveLesson(userId: 'u1', weekLabel: 'A', weekday: 2, subject: 'Science', startTime: '09:00', endTime: '10:00');
    final lessons = await repository.watchLessons('u1').first;

    // 2026-01-05 is Week A Monday; the following Monday (2026-01-12) is Week B.
    final weekAMonday = repository.lessonsFor(date: const CivilDate(2026, 1, 5), profile: profile, lessons: lessons);
    expect(weekAMonday.map((l) => l.subject), ['Maths']);

    final weekBMonday = repository.lessonsFor(date: const CivilDate(2026, 1, 12), profile: profile, lessons: lessons);
    expect(weekBMonday.map((l) => l.subject), ['Art']);
  });

  test('lessonsFor returns nothing for a two-week timetable with no anchor date yet', () async {
    const profile = AppSchoolProfile(userId: 'u1');
    await repository.saveLesson(userId: 'u1', weekLabel: 'A', weekday: 1, subject: 'Maths', startTime: '09:00', endTime: '10:00');
    final lessons = await repository.watchLessons('u1').first;

    expect(repository.lessonsFor(date: const CivilDate(2026, 1, 5), profile: profile, lessons: lessons), isEmpty);
  });

  test('isOpenOn is true inside a term and false during a closure inside that term', () async {
    await repository.saveTerm(userId: 'u1', title: 'Spring term', startDate: '2026-01-05', endDate: '2026-03-27');
    await repository.saveClosure(userId: 'u1', title: 'Half-term', type: SchoolClosureType.halfTerm, startDate: '2026-02-16', endDate: '2026-02-20');
    final terms = await repository.watchTerms('u1').first;
    final closures = await repository.watchClosures('u1').first;

    expect(repository.isOpenOn(date: const CivilDate(2026, 1, 12), terms: terms, closures: closures), isTrue);
    expect(repository.isOpenOn(date: const CivilDate(2026, 2, 18), terms: terms, closures: closures), isFalse);
    expect(repository.isOpenOn(date: const CivilDate(2026, 4, 1), terms: terms, closures: closures), isFalse);
  });

  test('weekLabelOn alternates weekly from the anchor and is null for a one-week timetable', () async {
    const twoWeek = AppSchoolProfile(userId: 'u1', anchorDate: '2026-01-05');
    expect(repository.weekLabelOn(const CivilDate(2026, 1, 5), twoWeek), WeekLabel.a);
    expect(repository.weekLabelOn(const CivilDate(2026, 1, 12), twoWeek), WeekLabel.b);

    const oneWeek = AppSchoolProfile(userId: 'u1', timetableType: SchoolTimetableType.oneWeek, anchorDate: '2026-01-05');
    expect(repository.weekLabelOn(const CivilDate(2026, 1, 5), oneWeek), isNull);
  });

  test('saveEvent then watchEventsInRange returns only events within the range', () async {
    await repository.saveEvent(userId: 'u1', title: 'Maths test', date: '2026-01-10', type: SchoolEventType.test);
    await repository.saveEvent(userId: 'u1', title: 'Summer fair', date: '2026-06-20');

    final inRange = await repository.watchEventsInRange('u1', const CivilDate(2026, 1, 1), const CivilDate(2026, 1, 31)).first;
    expect(inRange.map((e) => e.title), ['Maths test']);
  });
}
