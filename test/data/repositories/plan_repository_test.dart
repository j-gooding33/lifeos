import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/materialiser.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';

AppPlan _okPlan(Result<AppPlan, Failure> result) => result.when(
  ok: (p) => p,
  err: (f) => throw StateError('expected Ok, got ${f.message}'),
);

AppOccurrence _okOccurrence(Result<AppOccurrence, Failure> result) =>
    result.when(
      ok: (o) => o,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

void main() {
  late AppDatabase database;
  late PlanDao dao;
  late PlanRepository repository;
  late CivilDate today;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = PlanDao(database);
    repository = PlanRepository(dao, ActivityLogDao(database));
    today = CivilDate.fromDateTime(DateTime.now());
  });

  tearDown(() => database.close());

  test(
    'creating "every 3 days" produces the correct 120-day horizon (M6 DoD)',
    () async {
      final rule = IntervalDays(3, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Water the plants',
        rule: rule,
      );
      final plan = _okPlan(created);

      final occurrences = await dao.getOccurrencesForPlan(plan.id);
      final dates =
          occurrences.map((o) => CivilDate.parse(o.scheduledDate)).toList()
            ..sort();

      // Anchor itself fires, then every 3rd day through the 120-day horizon.
      const expectedCount = (Materialiser.horizonDaysActive ~/ 3) + 1;
      expect(dates.length, expectedCount);
      expect(dates.first, today);
      expect(dates.last, today.addDays(3 * (expectedCount - 1)));
      for (var i = 1; i < dates.length; i++) {
        expect(CivilDate.daysBetween(dates[i - 1], dates[i]), 3);
      }
      expect(
        dates.every(
          (d) => d.isAtOrBefore(today.addDays(Materialiser.horizonDaysActive)),
        ),
        isTrue,
      );
    },
  );

  test('editing a plan preserves exceptions (M6 DoD)', () async {
    final rule = IntervalDays(1, anchor: today);
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Daily read',
      rule: rule,
    );
    final plan = _okPlan(created);

    // Simulate an existing exception the way a move (M7) would create one:
    // a row at a date the current rule wouldn't naturally produce, flagged
    // isException so regeneration must leave it alone.
    final exceptionDate = today.addDays(50);
    await dao.upsertOccurrence(
      PlanOccurrencesCompanion.insert(
        id: 'exception-row',
        planId: plan.id,
        userId: plan.userId,
        scheduledDate: exceptionDate.toIso(),
        isException: const Value(true),
        status: const Value('pending'),
      ),
    );

    // Edit the schedule (every 1 day -> every 5 days): a real rule change,
    // which bumps generationVersion and regenerates.
    final newRule = IntervalDays(5, anchor: today);
    await repository.updatePlan(plan, plan.copyWith(rule: newRule));

    final row = await dao.getById(plan.id);
    expect(row!.generationVersion, plan.generationVersion + 1);

    final occurrences = await dao.getOccurrencesForPlan(plan.id);
    final exceptionRow = occurrences.firstWhere((o) => o.id == 'exception-row');
    expect(exceptionRow.scheduledDate, exceptionDate.toIso());
    expect(exceptionRow.isException, isTrue);
  });

  test(
    'editing a plan removes stale pending occurrences from the old schedule',
    () async {
      final rule = IntervalDays(1, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Daily thing',
        rule: rule,
      );
      final plan = _okPlan(created);

      final oldOccurrences = await dao.getOccurrencesForPlan(plan.id);
      // "Every day" for 120 days produces a row on day 2 — with the new
      // "every 5 days" rule that date should no longer exist.
      final dayTwo = today.addDays(2);
      expect(
        oldOccurrences.any((o) => o.scheduledDate == dayTwo.toIso()),
        isTrue,
      );

      await repository.updatePlan(
        plan,
        plan.copyWith(rule: IntervalDays(5, anchor: today)),
      );

      final newOccurrences = await dao.getOccurrencesForPlan(plan.id);
      expect(
        newOccurrences.any((o) => o.scheduledDate == dayTwo.toIso()),
        isFalse,
      );
    },
  );

  test(
    'completing an occurrence on a fixed plan does not touch future dates',
    () async {
      final rule = IntervalDays(1, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Daily thing',
        rule: rule,
      );
      final plan = _okPlan(created);

      final beforeDates = (await dao.getOccurrencesForPlan(plan.id))
          .map((o) => o.scheduledDate)
          .toSet();

      final occurrences = await repository.watchUpcoming(plan.id).first;
      final tomorrowRow = occurrences.firstWhere(
        (o) => o.scheduledDate == today.addDays(1),
      );
      await repository.completeOccurrence(tomorrowRow, plan);

      final afterDates = (await dao.getOccurrencesForPlan(plan.id))
          .map((o) => o.scheduledDate)
          .toSet();
      expect(afterDates, beforeDates);

      final updatedRow = (await dao.getOccurrencesForPlan(plan.id))
          .firstWhere((o) => o.id == tomorrowRow.id);
      expect(updatedRow.status, 'completed');
    },
  );

  test('completing an occurrence on a rolling plan restarts the rhythm from today (§9.4)', () async {
    final rule = IntervalDays(5, anchor: today);
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Water the plants',
      rule: rule,
      scheduleMode: ScheduleMode.rolling,
    );
    final plan = _okPlan(created);

    // Complete the anchor's own occurrence (scheduled for today) — the
    // spec's example ("water the plants every 5 days") completes it the
    // day it's actually due, and the clock restarts from that moment.
    final todaysOccurrence = (await dao.getOccurrencesForPlan(plan.id))
        .firstWhere((o) => o.scheduledDate == today.toIso());
    await repository.completeOccurrence(
      AppOccurrence(
        id: todaysOccurrence.id,
        planId: plan.id,
        scheduledDate: today,
      ),
      plan,
    );

    final row = await dao.getById(plan.id);
    expect(row!.generationVersion, plan.generationVersion + 1);

    final remaining =
        (await dao.getOccurrencesForPlan(plan.id))
            .where((o) => o.status == 'pending')
            .map((o) => CivilDate.parse(o.scheduledDate))
            .toList()
          ..sort();
    // The next pending date should now be 5 days after the completion date
    // (today), not 5 days after the original anchor.
    expect(remaining.first, today.addDays(5));
  });

  test('pausing a plan cancels occurrences inside the pause window', () async {
    final rule = IntervalDays(1, anchor: today);
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Daily thing',
      rule: rule,
    );
    final plan = _okPlan(created);

    await repository.pausePlan(plan.id, until: today.addDays(10));

    final occurrences = await dao.getOccurrencesForPlan(plan.id);
    final inWindow = occurrences.where(
      (o) =>
          CivilDate.parse(o.scheduledDate).isAtOrAfter(today) &&
          CivilDate.parse(o.scheduledDate).isAtOrBefore(today.addDays(10)),
    );
    expect(inWindow.every((o) => o.status == 'cancelled'), isTrue);

    final afterWindow = occurrences.where(
      (o) => CivilDate.parse(o.scheduledDate).isAfter(today.addDays(10)),
    );
    expect(afterWindow.every((o) => o.status == 'pending'), isTrue);
  });

  test('archiving then unarchiving a plan moves it between segments', () async {
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Side project',
      rule: IntervalDays(7, anchor: today),
    );
    final plan = _okPlan(created);

    expect(
      (await repository.watchActive('u1').first).map((p) => p.id),
      contains(plan.id),
    );

    await repository.archivePlan(plan.id);
    expect(
      (await repository.watchActive('u1').first).map((p) => p.id),
      isNot(contains(plan.id)),
    );
    expect(
      (await repository.watchArchived('u1').first).map((p) => p.id),
      contains(plan.id),
    );

    await repository.unarchivePlan(plan.id);
    expect(
      (await repository.watchActive('u1').first).map((p) => p.id),
      contains(plan.id),
    );
  });

  test(
    'missed sweep with markMissed policy marks past pending occurrences missed',
    () async {
      final anchor = today.addDays(-10);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Daily thing',
        rule: IntervalDays(1, anchor: anchor),
      );
      final plan = _okPlan(created);
      expect(plan.missedPolicy, MissedPolicy.markMissed);

      await repository.applyMissedSweep('u1');

      final past = (await dao.getOccurrencesForPlan(plan.id))
          .where((o) => CivilDate.parse(o.scheduledDate).isBefore(today));
      expect(past.every((o) => o.status == 'missed'), isTrue);
    },
  );

  test('a habit-kind plan appears in watchHabits, not watchActive', () async {
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Meditate',
      rule: IntervalDays(1, anchor: today),
      kind: PlanKind.habit,
    );
    final plan = _okPlan(created);

    expect(
      (await repository.watchHabits('u1').first).map((p) => p.id),
      contains(plan.id),
    );
    expect(
      (await repository.watchActive('u1').first).map((p) => p.id),
      isNot(contains(plan.id)),
    );
  });

  test(
    'moving one occurrence provably does not shift the series (M7 DoD)',
    () async {
      final rule = IntervalDays(3, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Every 3 days',
        rule: rule,
      );
      final plan = _okPlan(created);

      final beforeDates = (await dao.getOccurrencesForPlan(plan.id))
          .map((o) => o.scheduledDate)
          .toSet();
      final originalDate = today.addDays(3);
      final toMove = (await dao.getOccurrencesForPlan(plan.id))
          .firstWhere((o) => o.scheduledDate == originalDate.toIso());
      final moveTo = today.addDays(
        10,
      ); // 10 % 3 != 0 — not already a generated date.

      final result = await repository.moveOccurrence(
        AppOccurrence(
          id: toMove.id,
          planId: plan.id,
          scheduledDate: originalDate,
        ),
        plan,
        to: moveTo,
      );
      expect(result.isOk, isTrue);

      final afterRows = await dao.getOccurrencesForPlan(plan.id);
      final afterDates = afterRows.map((o) => o.scheduledDate).toSet();

      // Every date that existed before, other than the one that moved, is
      // exactly where it was — fixed scheduling means the rest of the series
      // is still computed straight from the anchor, untouched by the move.
      final expectedUnchanged = beforeDates.difference({originalDate.toIso()});
      expect(afterDates.intersection(expectedUnchanged), expectedUnchanged);

      final moved = afterRows.firstWhere((o) => o.id == toMove.id);
      expect(moved.scheduledDate, moveTo.toIso());
      expect(moved.originalDate, originalDate.toIso());
      expect(moved.isException, isTrue);
      expect(moved.status, 'pending');

      // Re-running materialisation (e.g. the detail screen reopening) must
      // not resurrect an occurrence at the vacated date — the move is
      // permanent, not just a one-time skip.
      await repository.ensureMaterialised(plan);
      final afterRegenerate = (await dao.getOccurrencesForPlan(plan.id))
          .map((o) => o.scheduledDate)
          .toSet();
      expect(afterRegenerate.contains(originalDate.toIso()), isFalse);
    },
  );

  test(
    'moving onto an occupied date conflicts unless merged (§8.4 point 4)',
    () async {
      final rule = IntervalDays(3, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Every 3 days',
        rule: rule,
      );
      final plan = _okPlan(created);

      final rows = await dao.getOccurrencesForPlan(plan.id);
      final toMove = rows.firstWhere((o) => o.scheduledDate == today.toIso());
      final destination = today.addDays(
        3,
      ); // already occupied by a generated occurrence.

      final conflictResult = await repository.moveOccurrence(
        AppOccurrence(id: toMove.id, planId: plan.id, scheduledDate: today),
        plan,
        to: destination,
      );
      expect(conflictResult.isOk, isFalse);
      final failure = conflictResult.when(ok: (_) => null, err: (f) => f);
      expect(failure, isA<OccurrenceConflictFailure>());

      final mergedResult = await repository.moveOccurrence(
        AppOccurrence(id: toMove.id, planId: plan.id, scheduledDate: today),
        plan,
        to: destination,
        mergeInto: true,
      );
      expect(mergedResult.isOk, isTrue);

      final afterRows = await dao.getOccurrencesForPlan(plan.id);
      // Exactly one occurrence remains at the destination date — the one
      // that moved there, not the one that was already there.
      final atDestination = afterRows.where(
        (o) => o.scheduledDate == destination.toIso(),
      );
      expect(atDestination, hasLength(1));
      expect(atDestination.single.id, toMove.id);
    },
  );

  test('moving an occurrence on a rolling plan recomputes future occurrences from the new date', () async {
    final rule = IntervalDays(5, anchor: today);
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Rolling plan',
      rule: rule,
      scheduleMode: ScheduleMode.rolling,
    );
    final plan = _okPlan(created);

    final anchorOccurrence = (await dao.getOccurrencesForPlan(plan.id))
        .firstWhere((o) => o.scheduledDate == today.toIso());
    final moveTo = today.addDays(2);
    await repository.moveOccurrence(
      AppOccurrence(
        id: anchorOccurrence.id,
        planId: plan.id,
        scheduledDate: today,
      ),
      plan,
      to: moveTo,
    );

    final row = await dao.getById(plan.id);
    expect(row!.generationVersion, plan.generationVersion + 1);

    final pendingDates =
        (await dao.getOccurrencesForPlan(plan.id))
            .where((o) => o.status == 'pending' && !o.isException)
            .map((o) => CivilDate.parse(o.scheduledDate))
            .toList()
          ..sort();
    expect(pendingDates.first, moveTo.addDays(5));
  });

  test('skipping an occurrence never breaks the streak (§8.5)', () async {
    final rule = IntervalDays(1, anchor: today.addDays(-2));
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Daily thing',
      rule: rule,
    );
    final plan = _okPlan(created);

    final rows = await dao.getOccurrencesForPlan(plan.id);
    // Complete two days ago and yesterday, skip today.
    await repository.completeOccurrence(
      AppOccurrence(
        id: rows
            .firstWhere((o) => o.scheduledDate == today.addDays(-2).toIso())
            .id,
        planId: plan.id,
        scheduledDate: today.addDays(-2),
      ),
      plan,
    );
    await repository.completeOccurrence(
      AppOccurrence(
        id: rows
            .firstWhere((o) => o.scheduledDate == today.addDays(-1).toIso())
            .id,
        planId: plan.id,
        scheduledDate: today.addDays(-1),
      ),
      plan,
    );
    final todayOccurrence = rows.firstWhere(
      (o) => o.scheduledDate == today.toIso(),
    );
    final skipResult = await repository.skipOccurrence(
      AppOccurrence(
        id: todayOccurrence.id,
        planId: plan.id,
        scheduledDate: today,
      ),
    );
    expect(skipResult.isOk, isTrue);

    final updated = (await dao.getOccurrencesForPlan(plan.id))
        .firstWhere((o) => o.id == todayOccurrence.id);
    expect(updated.status, 'skipped');
    expect(updated.isException, isTrue);

    final stats = await repository.watchStats(plan.id).first;
    expect(stats.streak, 2);
    expect(stats.missed, 0);
  });

  test('removing an occurrence deletes the row', () async {
    final rule = IntervalDays(1, anchor: today);
    final created = await repository.createPlan(
      userId: 'u1',
      title: 'Daily thing',
      rule: rule,
    );
    final plan = _okPlan(created);
    final target = (await dao.getOccurrencesForPlan(plan.id)).first;

    final result = await repository.removeOccurrence(target.id);
    expect(result.isOk, isTrue);
    final remaining = await dao.getOccurrencesForPlan(plan.id);
    expect(remaining.any((o) => o.id == target.id), isFalse);
  });

  test(
    'adding an extra occurrence creates an exception row outside the schedule',
    () async {
      final rule = IntervalDays(7, anchor: today);
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Weekly thing',
        rule: rule,
      );
      final plan = _okPlan(created);

      final extraDate = today.addDays(2); // not a date the rule would generate.
      final result = await repository.addExtraOccurrence(plan, extraDate);
      final extra = _okOccurrence(result);
      expect(extra.isException, isTrue);
      expect(extra.scheduledDate, extraDate);

      final rows = await dao.getOccurrencesForPlan(plan.id);
      final row = rows.firstWhere((o) => o.id == extra.id);
      expect(row.scheduledDate, extraDate.toIso());
      expect(row.isException, isTrue);

      // A later regeneration must not remove the manually-added extra.
      await repository.ensureMaterialised(plan);
      final afterRegenerate = await dao.getOccurrencesForPlan(plan.id);
      expect(afterRegenerate.any((o) => o.id == extra.id), isTrue);
    },
  );

  group('§16.5 media linking', () {
    test('linkOccurrenceToLibraryItem sets the link, unlinkOccurrence clears it', () async {
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Watch a film',
        rule: IntervalDays(3, anchor: today),
        mediaType: 'film',
      );
      final plan = _okPlan(created);
      final occurrence = (await repository.watchUpcoming(plan.id).first).first;

      await repository.linkOccurrenceToLibraryItem(occurrence.id, 'film1');
      var row = (await dao.getOccurrencesForPlan(plan.id)).firstWhere((o) => o.id == occurrence.id);
      expect(row.linkedEntityType, 'libraryItem');
      expect(row.linkedEntityId, 'film1');

      await repository.unlinkOccurrence(occurrence.id);
      row = (await dao.getOccurrencesForPlan(plan.id)).firstWhere((o) => o.id == occurrence.id);
      expect(row.linkedEntityType, null);
      expect(row.linkedEntityId, null);
    });

    test('linking then completing a linked occurrence marks the library item watched on the occurrence date', () async {
      final database2 = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database2.close);
      final planDao = PlanDao(database2);
      final libraryRepository = LibraryItemRepository(LibraryItemDao(database2));
      final repositoryWithMedia = PlanRepository(planDao, ActivityLogDao(database2), libraryItemRepository: libraryRepository);

      final film = (await libraryRepository.addManually(userId: 'u1', type: MediaType.film, title: 'Interstellar'))
          .when(ok: (i) => i, err: (f) => throw StateError(f.message));

      final created = await repositoryWithMedia.createPlan(
        userId: 'u1',
        title: 'Watch a film',
        rule: IntervalDays(3, anchor: today),
        mediaType: 'film',
      );
      final plan = _okPlan(created);
      // `watchUpcoming` is strictly after today, so pick the next scheduled
      // date rather than the anchor's own (today's) occurrence.
      final futureDate = today.addDays(3);
      final occurrence = (await repositoryWithMedia.watchUpcoming(plan.id).first).firstWhere((o) => o.scheduledDate == futureDate);

      await repositoryWithMedia.linkOccurrenceToLibraryItem(occurrence.id, film.id);
      final linked = (await repositoryWithMedia.watchUpcoming(plan.id).first).firstWhere((o) => o.id == occurrence.id);
      expect(linked.linkedEntityType, 'libraryItem');
      expect(linked.linkedEntityId, film.id);

      await repositoryWithMedia.completeOccurrence(linked, plan);

      final updatedFilm = await libraryRepository.watchById(film.id).first;
      expect(updatedFilm!.status, LibraryItemStatus.done);
      expect(updatedFilm.finishedAt, DateTime(futureDate.year, futureDate.month, futureDate.day));

      // Unlinking never touches the item's own status (§16.5).
      await repositoryWithMedia.unlinkOccurrence(occurrence.id);
      final unlinked = (await repositoryWithMedia.watchUpcoming(plan.id).first).firstWhere((o) => o.id == occurrence.id);
      final stillDone = await libraryRepository.watchById(film.id).first;
      expect(stillDone!.status, LibraryItemStatus.done);
      expect(unlinked.linkedEntityId, null);
    });

    test('completing a linked occurrence with no libraryItemRepository configured does not throw', () async {
      final created = await repository.createPlan(
        userId: 'u1',
        title: 'Watch a film',
        rule: IntervalDays(3, anchor: today),
        mediaType: 'film',
      );
      final plan = _okPlan(created);
      final occurrence = (await repository.watchUpcoming(plan.id).first).first;
      await repository.linkOccurrenceToLibraryItem(occurrence.id, 'film1');
      final linked = (await repository.watchUpcoming(plan.id).first).firstWhere((o) => o.id == occurrence.id);

      final result = await repository.completeOccurrence(linked, plan);
      expect(result.isOk, isTrue);
    });
  });
}
