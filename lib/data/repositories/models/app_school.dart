import 'package:life_os/core/school/school_week_engine.dart';

enum SchoolTimetableType { twoWeek, oneWeek }

enum SchoolClosureType { holiday, halfTerm, inset, custom }

enum SchoolEventType { test, exam, homework, event }

class AppSchoolProfile {
  const AppSchoolProfile({
    required this.userId,
    this.schoolName,
    this.dayStartTime,
    this.dayEndTime,
    this.timetableType = SchoolTimetableType.twoWeek,
    this.anchorWeekLabel = WeekLabel.a,
    this.anchorDate,
  });

  final String userId;
  final String? schoolName;

  /// Wall time `HH:mm` (§9.1).
  final String? dayStartTime;
  final String? dayEndTime;
  final SchoolTimetableType timetableType;
  final WeekLabel anchorWeekLabel;

  /// Civil date `YYYY-MM-DD` known to be [anchorWeekLabel]. Null until the
  /// user sets up their timetable — a two-week timetable can't compute
  /// Week A/B for any real date without it.
  final String? anchorDate;

  bool get isTwoWeek => timetableType == SchoolTimetableType.twoWeek;

  AppSchoolProfile copyWith({
    String? schoolName,
    String? dayStartTime,
    String? dayEndTime,
    SchoolTimetableType? timetableType,
    WeekLabel? anchorWeekLabel,
    String? anchorDate,
  }) {
    return AppSchoolProfile(
      userId: userId,
      schoolName: schoolName ?? this.schoolName,
      dayStartTime: dayStartTime ?? this.dayStartTime,
      dayEndTime: dayEndTime ?? this.dayEndTime,
      timetableType: timetableType ?? this.timetableType,
      anchorWeekLabel: anchorWeekLabel ?? this.anchorWeekLabel,
      anchorDate: anchorDate ?? this.anchorDate,
    );
  }
}

/// One recurring timetable slot. [weekLabel] is `'A'`/`'B'` for a two-week
/// timetable or `'ALL'` for a one-week one — matches
/// `school_week_engine.dart`'s `SchoolLessonSlot` string convention exactly
/// so converting between the two is a direct field copy.
class AppSchoolLesson {
  const AppSchoolLesson({
    required this.id,
    required this.userId,
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
  final String userId;
  final String weekLabel;
  final int weekday;
  final String subject;
  final String? teacher;
  final String? room;
  final String startTime;
  final String endTime;
  final String? colour;
}

class AppSchoolTerm {
  const AppSchoolTerm({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String userId;
  final String title;
  final String startDate;
  final String endDate;
}

class AppSchoolClosure {
  const AppSchoolClosure({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String userId;
  final String title;
  final SchoolClosureType type;
  final String startDate;
  final String endDate;
}

class AppSchoolEvent {
  const AppSchoolEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    this.type = SchoolEventType.event,
    this.time,
    this.subject,
    this.notes,
  });

  final String id;
  final String userId;
  final String title;
  final SchoolEventType type;
  final String date;
  final String? time;
  final String? subject;
  final String? notes;
}
