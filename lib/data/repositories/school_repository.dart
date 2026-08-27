import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_engine.dart' show DateRange;
import 'package:life_os/core/school/school_week_engine.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/school_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:uuid/uuid.dart';

/// M8 Parts 30-34. CRUD over the five School tables, plus the two
/// compositions every screen needs: "what lessons apply today" and
/// "is school even open today" — both delegate the actual date maths to
/// the pure `school_week_engine.dart` rather than duplicating it here.
class SchoolRepository {
  SchoolRepository(this._dao);

  final SchoolDao _dao;

  Stream<AppSchoolProfile?> watchProfile(String userId) {
    return _dao.watchProfile(userId).map((row) => row == null ? null : _profileToDomain(row));
  }

  Future<Result<void, Failure>> saveProfile(AppSchoolProfile profile) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertProfile(
        db.SchoolProfileCompanion(
          userId: Value(profile.userId),
          schoolName: Value(profile.schoolName),
          dayStartTime: Value(profile.dayStartTime),
          dayEndTime: Value(profile.dayEndTime),
          timetableType: Value(profile.isTwoWeek ? 'twoWeek' : 'oneWeek'),
          anchorWeekLabel: Value(profile.anchorWeekLabel == WeekLabel.a ? 'A' : 'B'),
          anchorDate: Value(profile.anchorDate),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveProfile failed: $e'));
    }
  }

  Stream<List<AppSchoolLesson>> watchLessons(String userId) {
    return _dao.watchLessons(userId).map((rows) => rows.map(_lessonToDomain).toList());
  }

  Future<Result<AppSchoolLesson, Failure>> saveLesson({
    required String userId,
    required String weekLabel,
    required int weekday,
    required String subject,
    required String startTime,
    required String endTime,
    String? id,
    String? teacher,
    String? room,
    String? colour,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lessonId = id ?? const Uuid().v4();
      await _dao.upsertLesson(
        db.SchoolLessonsCompanion(
          id: Value(lessonId),
          userId: Value(userId),
          weekLabel: Value(weekLabel),
          weekday: Value(weekday),
          subject: Value(subject),
          teacher: Value(teacher),
          room: Value(room),
          startTime: Value(startTime),
          endTime: Value(endTime),
          colour: Value(colour),
          updatedAt: Value(now),
          createdAt: Value(now),
        ),
      );
      return Ok(
        AppSchoolLesson(
          id: lessonId,
          userId: userId,
          weekLabel: weekLabel,
          weekday: weekday,
          subject: subject,
          teacher: teacher,
          room: room,
          startTime: startTime,
          endTime: endTime,
          colour: colour,
        ),
      );
    } on Object catch (e) {
      return Err(DatabaseFailure('saveLesson failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteLesson(String id) async {
    try {
      await _dao.deleteLesson(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteLesson failed: $e'));
    }
  }

  Stream<List<AppSchoolTerm>> watchTerms(String userId) {
    return _dao.watchTerms(userId).map((rows) => rows.map(_termToDomain).toList());
  }

  Future<Result<void, Failure>> saveTerm({
    required String userId,
    required String title,
    required String startDate,
    required String endDate,
    String? id,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertTerm(
        db.SchoolTermsCompanion(
          id: Value(id ?? const Uuid().v4()),
          userId: Value(userId),
          title: Value(title),
          startDate: Value(startDate),
          endDate: Value(endDate),
          createdAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveTerm failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteTerm(String id) async {
    try {
      await _dao.deleteTerm(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteTerm failed: $e'));
    }
  }

  Stream<List<AppSchoolClosure>> watchClosures(String userId) {
    return _dao.watchClosures(userId).map((rows) => rows.map(_closureToDomain).toList());
  }

  Future<Result<void, Failure>> saveClosure({
    required String userId,
    required String title,
    required SchoolClosureType type,
    required String startDate,
    required String endDate,
    String? id,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertClosure(
        db.SchoolClosuresCompanion(
          id: Value(id ?? const Uuid().v4()),
          userId: Value(userId),
          title: Value(title),
          type: Value(type.name),
          startDate: Value(startDate),
          endDate: Value(endDate),
          createdAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveClosure failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteClosure(String id) async {
    try {
      await _dao.deleteClosure(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteClosure failed: $e'));
    }
  }

  Stream<List<AppSchoolEvent>> watchEvents(String userId) {
    return _dao.watchEvents(userId).map((rows) => rows.map(_eventToDomain).toList());
  }

  Stream<List<AppSchoolEvent>> watchEventsInRange(String userId, CivilDate from, CivilDate through) {
    return _dao.watchEventsInRange(userId, from.toIso(), through.toIso()).map((rows) => rows.map(_eventToDomain).toList());
  }

  Future<Result<void, Failure>> saveEvent({
    required String userId,
    required String title,
    required String date,
    String? id,
    SchoolEventType type = SchoolEventType.event,
    String? time,
    String? subject,
    String? notes,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertEvent(
        db.SchoolEventsCompanion(
          id: Value(id ?? const Uuid().v4()),
          userId: Value(userId),
          title: Value(title),
          type: Value(type.name),
          date: Value(date),
          time: Value(time),
          subject: Value(subject),
          notes: Value(notes),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveEvent failed: $e'));
    }
  }

  Future<Result<void, Failure>> deleteEvent(String id) async {
    try {
      await _dao.deleteEvent(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteEvent failed: $e'));
    }
  }

  /// The lessons that actually apply on [date], per the pure week-parity
  /// engine — returns nothing if [profile] has no anchor date yet (a
  /// two-week timetable can't compute Week A/B without one) rather than
  /// guessing.
  List<SchoolLessonSlot> lessonsFor({
    required CivilDate date,
    required AppSchoolProfile profile,
    required List<AppSchoolLesson> lessons,
  }) {
    if (profile.isTwoWeek && profile.anchorDate == null) return const [];
    final anchor = profile.anchorDate == null ? date : CivilDate.parse(profile.anchorDate!);
    return lessonsOnDate(
      date: date,
      allLessons: lessons.map(_lessonToSlot).toList(),
      isTwoWeekTimetable: profile.isTwoWeek,
      anchorDate: anchor,
      anchorLabel: profile.anchorWeekLabel,
    );
  }

  bool isOpenOn({
    required CivilDate date,
    required List<AppSchoolTerm> terms,
    required List<AppSchoolClosure> closures,
  }) {
    return isSchoolOpen(
      date: date,
      terms: terms.map((t) => DateRange(CivilDate.parse(t.startDate), CivilDate.parse(t.endDate))).toList(),
      closures: closures.map((c) => DateRange(CivilDate.parse(c.startDate), CivilDate.parse(c.endDate))).toList(),
    );
  }

  WeekLabel? weekLabelOn(CivilDate date, AppSchoolProfile profile) {
    if (!profile.isTwoWeek || profile.anchorDate == null) return null;
    return weekLabelFor(anchorDate: CivilDate.parse(profile.anchorDate!), anchorLabel: profile.anchorWeekLabel, date: date);
  }

  SchoolLessonSlot _lessonToSlot(AppSchoolLesson l) {
    return SchoolLessonSlot(
      id: l.id,
      weekLabel: l.weekLabel,
      weekday: l.weekday,
      subject: l.subject,
      startTime: l.startTime,
      endTime: l.endTime,
      teacher: l.teacher,
      room: l.room,
      colour: l.colour,
    );
  }

  AppSchoolProfile _profileToDomain(db.SchoolProfileData row) {
    return AppSchoolProfile(
      userId: row.userId,
      schoolName: row.schoolName,
      dayStartTime: row.dayStartTime,
      dayEndTime: row.dayEndTime,
      timetableType: row.timetableType == 'oneWeek' ? SchoolTimetableType.oneWeek : SchoolTimetableType.twoWeek,
      anchorWeekLabel: row.anchorWeekLabel == 'B' ? WeekLabel.b : WeekLabel.a,
      anchorDate: row.anchorDate,
    );
  }

  AppSchoolLesson _lessonToDomain(db.SchoolLesson row) {
    return AppSchoolLesson(
      id: row.id,
      userId: row.userId,
      weekLabel: row.weekLabel,
      weekday: row.weekday,
      subject: row.subject,
      teacher: row.teacher,
      room: row.room,
      startTime: row.startTime,
      endTime: row.endTime,
      colour: row.colour,
    );
  }

  AppSchoolTerm _termToDomain(db.SchoolTerm row) {
    return AppSchoolTerm(id: row.id, userId: row.userId, title: row.title, startDate: row.startDate, endDate: row.endDate);
  }

  AppSchoolClosure _closureToDomain(db.SchoolClosure row) {
    return AppSchoolClosure(
      id: row.id,
      userId: row.userId,
      title: row.title,
      type: SchoolClosureType.values.firstWhere((t) => t.name == row.type, orElse: () => SchoolClosureType.custom),
      startDate: row.startDate,
      endDate: row.endDate,
    );
  }

  AppSchoolEvent _eventToDomain(db.SchoolEvent row) {
    return AppSchoolEvent(
      id: row.id,
      userId: row.userId,
      title: row.title,
      type: SchoolEventType.values.firstWhere((t) => t.name == row.type, orElse: () => SchoolEventType.event),
      date: row.date,
      time: row.time,
      subject: row.subject,
      notes: row.notes,
    );
  }
}
