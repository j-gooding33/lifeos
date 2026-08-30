import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/features/home/application/briefing.dart';

DateTime _t(int hour, [int minute = 0]) => DateTime(2026, 9, 5, hour, minute);

AppTask _task(String id, {String? dueDate, String? dueTime, DateTime? completedAt}) {
  return AppTask(id: id, userId: 'u1', title: id, dueDate: dueDate, dueTime: dueTime, completedAt: completedAt);
}

void main() {
  group('freeTimeWindows', () {
    final dayStart = _t(8);
    final dayEnd = _t(22);

    test('finds the gaps before, between, and after busy blocks', () {
      final windows = freeTimeWindows(
        busy: [(_t(10), _t(11)), (_t(14), _t(15, 30))],
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
      expect(windows.length, 3);
      expect(windows[0].start, _t(8));
      expect(windows[0].end, _t(10));
      expect(windows[1].start, _t(11));
      expect(windows[1].end, _t(14));
      expect(windows[2].start, _t(15, 30));
      expect(windows[2].end, _t(22));
    });

    test('a fully free day is one window spanning the whole range', () {
      final windows = freeTimeWindows(busy: const [], dayStart: dayStart, dayEnd: dayEnd);
      expect(windows.single.start, dayStart);
      expect(windows.single.end, dayEnd);
    });

    test('overlapping busy intervals are merged, not double-counted', () {
      final windows = freeTimeWindows(
        busy: [(_t(10), _t(12)), (_t(11), _t(13))],
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
      expect(windows.length, 2);
      expect(windows[0].end, _t(10));
      expect(windows[1].start, _t(13));
    });

    test('a gap shorter than the minimum is dropped, not shown as a sliver', () {
      final windows = freeTimeWindows(
        busy: [(_t(10), _t(11)), (_t(11, 15), _t(12))],
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
      expect(windows.any((w) => w.start == _t(11) && w.end == _t(11, 15)), isFalse);
    });

    test('a busy block entirely outside the day range is ignored', () {
      final windows = freeTimeWindows(
        busy: [(_t(6), _t(7))],
        dayStart: dayStart,
        dayEnd: dayEnd,
      );
      expect(windows.single.start, _t(8));
      expect(windows.single.end, _t(22));
    });

    test('an inverted or empty day range produces no windows', () {
      expect(freeTimeWindows(busy: const [], dayStart: _t(22), dayEnd: _t(8)), isEmpty);
    });
  });

  group('nearestDeadline', () {
    test('picks the soonest incomplete task by date then time', () {
      final tasks = [
        _task('late', dueDate: '2026-09-10', dueTime: '09:00'),
        _task('soonest', dueDate: '2026-09-05', dueTime: '14:00'),
        _task('same-day-later', dueDate: '2026-09-05', dueTime: '18:00'),
      ];
      expect(nearestDeadline(tasks)?.id, 'soonest');
    });

    test('an undated task on the same day sorts after a timed one', () {
      final tasks = [
        _task('undated', dueDate: '2026-09-05'),
        _task('timed', dueDate: '2026-09-05', dueTime: '09:00'),
      ];
      expect(nearestDeadline(tasks)?.id, 'timed');
    });

    test('completed tasks never count as a deadline', () {
      final tasks = [_task('done', dueDate: '2026-09-01', completedAt: DateTime(2026, 9))];
      expect(nearestDeadline(tasks), isNull);
    });

    test('no due dates at all means no deadline, not a crash', () {
      expect(nearestDeadline([_task('someday')]), isNull);
    });
  });

  group('civilDateTimeAt', () {
    test('combines a date and a wall time', () {
      final result = civilDateTimeAt(const CivilDate(2026, 9, 5), '14:30');
      expect(result, DateTime(2026, 9, 5, 14, 30));
    });

    test('null time means no fixed slot, not midnight', () {
      expect(civilDateTimeAt(const CivilDate(2026, 9, 5), null), isNull);
    });

    test('an unparseable time is treated the same as no time', () {
      expect(civilDateTimeAt(const CivilDate(2026, 9, 5), 'lunchtime'), isNull);
    });
  });

  group('morningSentence', () {
    test('names both counts when there are tasks and plans', () {
      final s = morningSentence(taskCount: 2, occurrenceCount: 1, nearestDeadline: null);
      expect(s, 'You have 2 tasks and 1 plan today.');
    });

    test('an empty day says so plainly', () {
      expect(morningSentence(taskCount: 0, occurrenceCount: 0, nearestDeadline: null), 'Nothing scheduled today.');
    });

    test('appends the nearest deadline by name when there is one', () {
      final s = morningSentence(taskCount: 1, occurrenceCount: 0, nearestDeadline: _task('Renew passport'));
      expect(s, contains('Renew passport is the nearest deadline.'));
    });
  });

  group('eveningSentence', () {
    test('reports what was done and what is next', () {
      expect(eveningSentence(completedCount: 3, tomorrowCount: 1), 'You completed 3 things today. Tomorrow has 1 thing lined up.');
    });

    test('is honest about a quiet day in both directions', () {
      expect(eveningSentence(completedCount: 0, tomorrowCount: 0), 'Nothing marked done today. Nothing on tomorrow yet.');
    });
  });
}
