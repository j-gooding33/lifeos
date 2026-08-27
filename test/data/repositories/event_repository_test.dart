import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/event_repository.dart';

void main() {
  late AppDatabase database;
  late EventRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = EventRepository(EventDao(database));
  });

  tearDown(() => database.close());

  test(
    'creating an event makes it appear in a range query covering its date',
    () async {
      final start = DateTime(2026, 9, 1, 18, 30);
      final created = await repository.createEvent(
        userId: 'u1',
        title: 'Dinner',
        startAt: start,
      );
      final event = created.when(
        ok: (e) => e,
        err: (_) => throw StateError('expected Ok'),
      );

      final inRange = await repository
          .watchInRange(
            'u1',
            const CivilDate(2026, 9, 1),
            const CivilDate(2026, 9, 1),
          )
          .first;
      expect(inRange.map((e) => e.id), contains(event.id));

      final outOfRange = await repository
          .watchInRange(
            'u1',
            const CivilDate(2026, 9, 2),
            const CivilDate(2026, 9, 5),
          )
          .first;
      expect(outOfRange.map((e) => e.id), isNot(contains(event.id)));
    },
  );

  test('updating an event changes its title and time', () async {
    final created = await repository.createEvent(
      userId: 'u1',
      title: 'Draft title',
      startAt: DateTime(2026, 9, 1, 10),
    );
    final event = created.when(
      ok: (e) => e,
      err: (_) => throw StateError('expected Ok'),
    );

    await repository.updateEvent(
      event.copyWith(title: 'Final title', startAt: DateTime(2026, 9, 1, 14)),
    );

    final updated = await repository.watchById(event.id).first;
    expect(updated!.title, 'Final title');
    expect(updated.startAt.hour, 14);
  });

  test('deleting an event soft-deletes it out of range queries', () async {
    final created = await repository.createEvent(
      userId: 'u1',
      title: 'Gone soon',
      startAt: DateTime(2026, 9),
    );
    final event = created.when(
      ok: (e) => e,
      err: (_) => throw StateError('expected Ok'),
    );

    await repository.deleteEvent(event.id);

    final inRange = await repository
        .watchInRange(
          'u1',
          const CivilDate(2026, 9, 1),
          const CivilDate(2026, 9, 1),
        )
        .first;
    expect(inRange, isEmpty);
  });

  test(
    'an all-day event has no time-of-day but does have a start date',
    () async {
      final created = await repository.createEvent(
        userId: 'u1',
        title: 'Public holiday',
        startAt: DateTime(2026, 12, 25),
        allDay: true,
      );
      final event = created.when(
        ok: (e) => e,
        err: (_) => throw StateError('expected Ok'),
      );
      expect(event.allDay, isTrue);
      expect(event.startDate, const CivilDate(2026, 12, 25));
    },
  );
}
