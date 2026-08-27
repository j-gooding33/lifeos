import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/materialiser.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';

AppPlan _okPlan(Result<AppPlan, Failure> result) => result.when(
  ok: (p) => p,
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
    repository = PlanRepository(dao);
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
}
