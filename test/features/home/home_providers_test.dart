import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/features/home/application/home_providers.dart';

AppTask _task(String title, {String? dueDate}) {
  return AppTask(id: title, userId: 'u1', title: title, dueDate: dueDate);
}

void main() {
  test('groups dated tasks by day and undated tasks separately', () {
    final result = bucketUpcoming([
      _task('Dentist', dueDate: '2026-09-01'),
      _task('Gym', dueDate: '2026-09-01'),
      _task('Trip', dueDate: '2026-09-03'),
      _task('Read that book'),
      _task('Learn Spanish'),
    ]);

    expect(result.byDay['2026-09-01']!.count, 2);
    expect(result.byDay['2026-09-01']!.firstTitle, 'Dentist');
    expect(result.byDay['2026-09-03']!.count, 1);
    expect(result.byDay['2026-09-03']!.firstTitle, 'Trip');
    expect(result.undated.count, 2);
    expect(result.undated.firstTitle, 'Read that book');
  });

  test('empty input produces empty buckets, not a crash', () {
    final result = bucketUpcoming(const []);
    expect(result.byDay, isEmpty);
    expect(result.undated.isEmpty, isTrue);
    expect(result.undated.firstTitle, isNull);
  });

  test('HomeSnapshot.hasNothingUpcoming is true only when every bucket is empty', () {
    const empty = UpcomingBucket(count: 0, firstTitle: null);
    const full = UpcomingBucket(count: 1, firstTitle: 'Something');

    const allEmpty = HomeSnapshot(
      focusItems: [],
      doneToday: 0,
      totalToday: 0,
      upcomingByDay: {'2026-09-01': empty},
      upcomingUndated: empty,
      recent: [],
    );
    const oneFull = HomeSnapshot(
      focusItems: [],
      doneToday: 0,
      totalToday: 0,
      upcomingByDay: {'2026-09-01': full},
      upcomingUndated: empty,
      recent: [],
    );

    expect(allEmpty.hasNothingUpcoming, isTrue);
    expect(oneFull.hasNothingUpcoming, isFalse);
  });
}
