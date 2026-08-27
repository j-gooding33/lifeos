import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/materialiser.dart';
import 'package:life_os/core/scheduling/missed_sweep.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/scheduling/recurrence_rule_json.dart';
import 'package:life_os/core/scheduling/recurrence_rule_reanchor.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:uuid/uuid.dart';

/// §7, §8.1, §9.5–§9.7. Plans and their materialised occurrences. Every
/// write that can change *which dates should exist* — create, edit,
/// pause/resume, a rolling-mode completion, a move — goes through
/// [_regenerate], which is the one place that knows how to touch
/// occurrences without disturbing history or exceptions (§7.6 pitfall 3).
class PlanRepository {
  PlanRepository(
    this._dao,
    this._activityLog, {
    Materialiser? materialiser,
    MissedSweep? missedSweep,
  }) : _materialiser = materialiser ?? const Materialiser(),
       _missedSweep = missedSweep ?? const MissedSweep();

  final PlanDao _dao;
  final ActivityLogDao _activityLog;
  final Materialiser _materialiser;
  final MissedSweep _missedSweep;

  CivilDate get _today => CivilDate.fromDateTime(DateTime.now());

  Stream<List<AppPlan>> watchActive(String userId) =>
      _dao.watchActive(userId, _today.toIso()).map(_toDomainList);

  Stream<List<AppPlan>> watchHabits(String userId) =>
      _dao.watchHabits(userId).map(_toDomainList);

  Stream<List<AppPlan>> watchPaused(String userId) =>
      _dao.watchPaused(userId, _today.toIso()).map(_toDomainList);

  Stream<List<AppPlan>> watchArchived(String userId) =>
      _dao.watchArchived(userId).map(_toDomainList);

  Stream<AppPlan?> watchById(String id) =>
      _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));

  Stream<List<AppOccurrence>> watchUpcoming(String planId, {int limit = 30}) {
    return _dao
        .watchUpcoming(planId, _today.toIso(), limit: limit)
        .map(_toOccurrenceList);
  }

  Stream<List<AppOccurrence>> watchHistory(String planId, {int limit = 20}) {
    return _dao
        .watchHistory(planId, _today.toIso(), limit: limit)
        .map(_toOccurrenceList);
  }

  Stream<PlanStats> watchStats(String planId) {
    return _dao
        .watchAllForPlan(planId)
        .map((rows) => _computeStats(rows, _today));
  }

  Stream<List<AppOccurrence>> watchOccurrencesInRange(
    String userId,
    CivilDate from,
    CivilDate through,
  ) {
    return _dao
        .watchOccurrencesInRange(userId, from.toIso(), through.toIso())
        .map(_toOccurrenceList);
  }

  Stream<List<AppOccurrence>> watchPlanOccurrencesInRange(
    String planId,
    CivilDate from,
    CivilDate through,
  ) {
    return _dao
        .watchOccurrencesInRangeForPlan(planId, from.toIso(), through.toIso())
        .map(_toOccurrenceList);
  }

  Stream<AppOccurrence?> watchOccurrenceById(String occurrenceId) {
    return _dao
        .watchOccurrenceById(occurrenceId)
        .map((row) => row == null ? null : _toOccurrence(row));
  }

  Stream<AppOccurrence?> watchOccurrenceOn(String planId, CivilDate date) {
    return _dao
        .watchOccurrenceOnDate(planId, date.toIso())
        .map((row) => row == null ? null : _toOccurrence(row));
  }

  Future<Result<AppPlan, Failure>> createPlan({
    required String userId,
    required String title,
    required RecurrenceRule rule,
    PlanKind kind = PlanKind.plan,
    String? icon,
    String? colour,
    String? category,
    String? mediaType,
    CivilDate? startDate,
    String? timeOfDay,
    int? durationMinutes,
    MissedPolicy missedPolicy = MissedPolicy.markMissed,
    ScheduleMode scheduleMode = ScheduleMode.fixed,
    String? goalId,
    String? notes,
  }) async {
    try {
      final plan = AppPlan(
        id: const Uuid().v4(),
        userId: userId,
        kind: kind,
        title: title,
        icon: icon,
        colour: colour,
        category: category,
        mediaType: mediaType,
        rule: rule,
        startDate: startDate,
        timeOfDay: timeOfDay,
        durationMinutes: durationMinutes,
        missedPolicy: missedPolicy,
        scheduleMode: scheduleMode,
        goalId: goalId,
        notes: notes,
      );
      await _savePlan(plan);
      await _regenerate(plan);
      return Ok(plan);
    } on Object catch (e) {
      return Err(DatabaseFailure('createPlan failed: $e'));
    }
  }

  /// [previous] is what's currently stored, [updated] is the caller's
  /// edited copy — comparing the two is how this decides whether the
  /// schedule itself changed (bump `generationVersion`, regenerate) or only
  /// cosmetic fields did (title/icon/notes: just save the row).
  Future<Result<void, Failure>> updatePlan(
    AppPlan previous,
    AppPlan updated,
  ) async {
    try {
      final scheduleChanged =
          previous.rule.toJsonString() != updated.rule.toJsonString() ||
          previous.startDate != updated.startDate ||
          previous.pauseFrom != updated.pauseFrom ||
          previous.pauseUntil != updated.pauseUntil;

      final toSave = scheduleChanged
          ? updated.copyWith(generationVersion: previous.generationVersion + 1)
          : updated.copyWith(generationVersion: previous.generationVersion);
      await _savePlan(toSave);
      if (scheduleChanged) await _regenerate(toSave);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updatePlan failed: $e'));
    }
  }

  Future<Result<void, Failure>> archivePlan(String id) =>
      _setArchived(id, archived: true);

  Future<Result<void, Failure>> unarchivePlan(String id) =>
      _setArchived(id, archived: false);

  Future<Result<void, Failure>> _setArchived(
    String id, {
    required bool archived,
  }) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) return Err(NotFoundFailure('Plan $id not found'));
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.setArchivedAt(id, archived ? now : null, now);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setArchived failed: $e'));
    }
  }

  Future<Result<void, Failure>> pausePlan(
    String id, {
    required CivilDate until,
  }) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) return Err(NotFoundFailure('Plan $id not found'));
      final plan = _toDomain(row);
      final updated = plan.copyWith(pauseFrom: _today, pauseUntil: until);
      await updatePlan(plan, updated);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('pausePlan failed: $e'));
    }
  }

  Future<Result<void, Failure>> resumePlan(String id) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) return Err(NotFoundFailure('Plan $id not found'));
      final plan = _toDomain(row);
      final updated = plan.copyWith(clearPause: true);
      await updatePlan(plan, updated);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('resumePlan failed: $e'));
    }
  }

  Future<Result<AppPlan, Failure>> duplicatePlan(AppPlan plan) async {
    try {
      final copy = AppPlan(
        id: const Uuid().v4(),
        userId: plan.userId,
        kind: plan.kind,
        title: '${plan.title} (copy)',
        icon: plan.icon,
        colour: plan.colour,
        category: plan.category,
        mediaType: plan.mediaType,
        rule: plan.rule,
        startDate: plan.startDate,
        timeOfDay: plan.timeOfDay,
        durationMinutes: plan.durationMinutes,
        missedPolicy: plan.missedPolicy,
        scheduleMode: plan.scheduleMode,
        goalId: plan.goalId,
        notes: plan.notes,
      );
      await _savePlan(copy);
      await _regenerate(copy);
      return Ok(copy);
    } on Object catch (e) {
      return Err(DatabaseFailure('duplicatePlan failed: $e'));
    }
  }

  Future<Result<void, Failure>> deletePlan(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deletePlan failed: $e'));
    }
  }

  /// §9.5 trigger: "plan detail open." Idempotent — safe to call every time
  /// the detail screen loads.
  Future<void> ensureMaterialised(AppPlan plan) => _regenerate(plan);

  Future<Result<void, Failure>> completeOccurrence(
    AppOccurrence occurrence,
    AppPlan plan,
  ) async {
    try {
      final now = DateTime.now();
      await _dao.updateOccurrenceStatus(
        occurrence.id,
        status: 'completed',
        completedAt: now.millisecondsSinceEpoch,
      );
      if (plan.scheduleMode == ScheduleMode.rolling) {
        final reanchored = plan.copyWith(
          rule: reanchorRule(plan.rule, CivilDate.fromDateTime(now)),
          generationVersion: plan.generationVersion + 1,
        );
        await _savePlan(reanchored);
        await _regenerate(reanchored);
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('completeOccurrence failed: $e'));
    }
  }

  Future<Result<void, Failure>> uncompleteOccurrence(
    AppOccurrence occurrence,
  ) async {
    try {
      await _dao.updateOccurrenceStatus(
        occurrence.id,
        status: 'pending',
        clearCompletedAt: true,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('uncompleteOccurrence failed: $e'));
    }
  }

  /// §8.4. Moves [occurrence] to [to]. Under `fixed` scheduling this never
  /// touches any other occurrence — the rest of the series still comes from
  /// `anchorDate`, unchanged (point 2). Under `rolling`, future
  /// pending/non-exception occurrences are recomputed from [to] as the new
  /// effective anchor (point 3). If another occurrence of the same plan
  /// already sits on [to] (point 4: "Merge, or keep both?"): with neither
  /// flag set, returns [OccurrenceConflictFailure] so the caller can ask;
  /// [keepBoth] proceeds and leaves both rows (the partial unique index on
  /// generated rows already permits an exception alongside one); [mergeInto]
  /// removes the existing one first so only [occurrence] ends up at [to].
  Future<Result<void, Failure>> moveOccurrence(
    AppOccurrence occurrence,
    AppPlan plan, {
    required CivilDate to,
    bool keepBoth = false,
    bool mergeInto = false,
  }) async {
    try {
      final conflict = await _dao.getOccurrenceOnDate(plan.id, to.toIso());
      if (conflict != null && conflict.id != occurrence.id) {
        if (mergeInto) {
          await _dao.deleteOccurrence(conflict.id);
        } else if (!keepBoth) {
          return Err(OccurrenceConflictFailure(conflict.id));
        }
      }

      await _dao.moveOccurrence(
        occurrence.id,
        originalDate: occurrence.scheduledDate.toIso(),
        newDate: to.toIso(),
      );
      await _activityLog.log(
        id: const Uuid().v4(),
        userId: plan.userId,
        entityType: 'plan_occurrence',
        entityId: occurrence.id,
        action: 'moved',
        payload:
            '{"from":"${occurrence.scheduledDate.toIso()}","to":"${to.toIso()}"}',
      );

      if (plan.scheduleMode == ScheduleMode.rolling) {
        final reanchored = plan.copyWith(
          rule: reanchorRule(plan.rule, to),
          generationVersion: plan.generationVersion + 1,
        );
        await _savePlan(reanchored);
        await _regenerate(reanchored);
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('moveOccurrence failed: $e'));
    }
  }

  /// §8.5. Skipping is an active, honest choice: it never counts as missed
  /// and never breaks a streak (`_computeStats` treats `skipped` the same
  /// as `cancelled`), unlike `missed` which the [MissedSweep] applies
  /// passively when nothing was done in time.
  Future<Result<void, Failure>> skipOccurrence(AppOccurrence occurrence) async {
    try {
      await _dao.updateOccurrenceStatus(
        occurrence.id,
        status: 'skipped',
        isException: true,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('skipOccurrence failed: $e'));
    }
  }

  Future<Result<void, Failure>> setOccurrenceNote(
    String occurrenceId,
    String? note,
  ) async {
    try {
      await _dao.setOccurrenceNote(occurrenceId, note);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setOccurrenceNote failed: $e'));
    }
  }

  /// §8.3 "Remove this date" — a hard delete, matching how stale generated
  /// rows are already cleaned up in [_regenerate]; occurrences have no
  /// established soft-delete convention to preserve here.
  Future<Result<void, Failure>> removeOccurrence(String occurrenceId) async {
    try {
      await _dao.deleteOccurrence(occurrenceId);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('removeOccurrence failed: $e'));
    }
  }

  /// §8.2 long-press on a blank calendar day: a genuinely extra occurrence,
  /// not one the rule would generate — random id (§9.7: "user-created
  /// extras use uuidV4"), `isException = true` so regeneration never
  /// touches or duplicates it.
  Future<Result<AppOccurrence, Failure>> addExtraOccurrence(
    AppPlan plan,
    CivilDate date,
  ) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertOccurrence(
        db.PlanOccurrencesCompanion.insert(
          id: id,
          planId: plan.id,
          userId: plan.userId,
          scheduledDate: date.toIso(),
          status: const Value('pending'),
          isException: const Value(true),
          generationVersion: Value(plan.generationVersion),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      return Ok(
        AppOccurrence(
          id: id,
          planId: plan.id,
          scheduledDate: date,
          isException: true,
        ),
      );
    } on Object catch (e) {
      return Err(DatabaseFailure('addExtraOccurrence failed: $e'));
    }
  }

  /// §9.6, run opportunistically whenever the Plans list loads rather than
  /// by a true midnight-triggered background job — see DECISIONS.md (same
  /// category of deferral as Home's date-rollover service in M5).
  Future<void> applyMissedSweep(String userId) async {
    for (final segment in [
      await _dao.watchActive(userId, _today.toIso()).first,
      await _dao.watchHabits(userId).first,
    ]) {
      for (final row in segment) {
        await _sweepPlan(_toDomain(row));
      }
    }
  }

  Future<void> _sweepPlan(AppPlan plan) async {
    final rows = await _dao.getOccurrencesForPlan(plan.id);
    final pastPending = rows.where(
      (r) =>
          r.status == 'pending' &&
          CivilDate.parse(r.scheduledDate).isBefore(_today),
    );
    final pending = [
      for (final r in pastPending)
        PendingOccurrence(r.id, plan.id, CivilDate.parse(r.scheduledDate)),
    ];
    if (pending.isEmpty) return;
    final results = _missedSweep.apply(
      pastPending: pending,
      today: _today,
      policy: plan.missedPolicy,
    );
    for (final result in results) {
      switch (result.outcome) {
        case SweepOutcome.cancelled:
          await _dao.updateOccurrenceStatus(
            result.occurrenceId,
            status: 'cancelled',
          );
        case SweepOutcome.missed:
          await _dao.updateOccurrenceStatus(
            result.occurrenceId,
            status: 'missed',
          );
        case SweepOutcome.rolledForward:
          await _dao.updateOccurrenceStatus(
            result.occurrenceId,
            status: 'pending',
            scheduledDate: result.newDate!.toIso(),
          );
        case SweepOutcome.unchanged:
          break;
      }
    }
  }

  Future<void> _savePlan(AppPlan plan) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.PlansCompanion(
        id: Value(plan.id),
        userId: Value(plan.userId),
        kind: Value(plan.kind.name),
        title: Value(plan.title),
        icon: Value(plan.icon),
        colour: Value(plan.colour),
        category: Value(plan.category),
        mediaType: Value(plan.mediaType),
        rule: Value(plan.rule.toJsonString()),
        generationVersion: Value(plan.generationVersion),
        anchorDate: Value(plan.rule.anchor.toIso()),
        startDate: Value(plan.startDate.toIso()),
        endDate: Value(plan.endDate?.toIso()),
        endAfterCount: Value(plan.endAfterCount),
        timeOfDay: Value(plan.timeOfDay),
        durationMinutes: Value(plan.durationMinutes),
        missedPolicy: Value(plan.missedPolicy.name),
        scheduleMode: Value(plan.scheduleMode.name),
        pauseFrom: Value(plan.pauseFrom?.toIso()),
        pauseUntil: Value(plan.pauseUntil?.toIso()),
        goalId: Value(plan.goalId),
        notes: Value(plan.notes),
        archivedAt: Value(plan.archivedAt?.millisecondsSinceEpoch),
        createdAt: Value(plan.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  /// The one place that writes occurrence rows. Only ever inserts a new
  /// row or updates one whose status is still `pending`/`cancelled` — a
  /// `completed`/`missed` row is a historical fact and is never touched,
  /// and dates already marked `isException` are never emitted by
  /// [Materialiser] in the first place (§7.6 pitfall 3).
  Future<void> _regenerate(AppPlan plan) async {
    final horizon = _today.addDays(Materialiser.horizonDaysActive);
    final existingRows = await _dao.getOccurrencesForPlan(plan.id);
    final existingByDate = {
      for (final r in existingRows) CivilDate.parse(r.scheduledDate): r,
    };

    final materialised = _materialiser.materialise(
      rule: plan.rule,
      through: horizon,
      existing: [
        for (final r in existingRows) ...[
          ExistingOccurrence(
            CivilDate.parse(r.scheduledDate),
            isException: r.isException,
          ),
          // §8.4: a moved occurrence's *vacated* date must also stay
          // vacant on regeneration — otherwise the rule, blind to the
          // move, would happily re-fill the date it left behind.
          if (r.isException && r.originalDate != null)
            ExistingOccurrence(
              CivilDate.parse(r.originalDate!),
              isException: true,
            ),
        ],
      ],
      pauseFrom: plan.pauseFrom,
      pauseUntil: plan.pauseUntil,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final occurrence in materialised) {
      if (occurrence.date.isBefore(plan.startDate)) continue;
      final existing = existingByDate[occurrence.date];
      if (existing != null &&
          (existing.status == 'completed' || existing.status == 'missed')) {
        continue;
      }
      final sameGeneration =
          existing != null &&
          existing.generationVersion == plan.generationVersion;
      final id = sameGeneration
          ? existing.id
          : const Uuid().v5(
              plan.id,
              '${plan.generationVersion}|${occurrence.date.toIso()}',
            );
      final status = occurrence.status == MaterialisedStatus.cancelled
          ? 'cancelled'
          : 'pending';
      await _dao.upsertOccurrence(
        db.PlanOccurrencesCompanion.insert(
          id: id,
          planId: plan.id,
          userId: plan.userId,
          scheduledDate: occurrence.date.toIso(),
          status: Value(status),
          generationVersion: Value(plan.generationVersion),
          createdAt: sameGeneration ? Value(existing.createdAt) : Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    final staleFutureRows = existingRows.where(
      (r) =>
          !r.isException &&
          (r.status == 'pending' || r.status == 'cancelled') &&
          r.generationVersion != plan.generationVersion &&
          CivilDate.parse(r.scheduledDate).isAtOrAfter(_today),
    );
    for (final row in staleFutureRows) {
      await _dao.deleteOccurrence(row.id);
    }
  }

  PlanStats _computeStats(List<db.PlanOccurrence> rows, CivilDate today) {
    var done = 0;
    var missed = 0;
    for (final row in rows) {
      if (row.status == 'completed') done++;
      if (row.status == 'missed') missed++;
    }
    final rate = (done + missed) == 0 ? 0.0 : done / (done + missed);

    final pastRows =
        rows
            .where((r) => CivilDate.parse(r.scheduledDate).isAtOrBefore(today))
            .toList()
          ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    var streak = 0;
    for (final row in pastRows) {
      if (row.status == 'completed') {
        streak++;
      } else if (row.status == 'cancelled' || row.status == 'skipped') {
        // §8.5: skipped is an active, honest choice — never breaks a
        // streak, same as a pause-window/skip-policy cancellation.
        continue;
      } else {
        break;
      }
    }

    final thisWeekStart = today.startOfWeek();
    final heatmap = <double?>[
      for (var i = 11; i >= 0; i--)
        _weekRatio(rows, thisWeekStart.addDays(-7 * i)),
    ];

    return PlanStats(
      done: done,
      rate: rate,
      streak: streak,
      missed: missed,
      weeklyHeatmap: heatmap,
    );
  }

  double? _weekRatio(List<db.PlanOccurrence> rows, CivilDate weekStart) {
    final weekEnd = weekStart.addDays(6);
    var done = 0;
    var missed = 0;
    for (final row in rows) {
      final date = CivilDate.parse(row.scheduledDate);
      if (date.isBefore(weekStart) || date.isAfter(weekEnd)) continue;
      if (row.status == 'completed') done++;
      if (row.status == 'missed') missed++;
    }
    final total = done + missed;
    return total == 0 ? null : done / total;
  }

  List<AppPlan> _toDomainList(List<db.Plan> rows) =>
      rows.map(_toDomain).toList();

  AppPlan _toDomain(db.Plan row) {
    return AppPlan(
      id: row.id,
      userId: row.userId,
      kind: row.kind == 'habit' ? PlanKind.habit : PlanKind.plan,
      title: row.title,
      icon: row.icon,
      colour: row.colour,
      category: row.category,
      mediaType: row.mediaType,
      rule: recurrenceRuleFromJsonString(row.rule),
      startDate: CivilDate.parse(row.startDate),
      endDate: row.endDate == null ? null : CivilDate.parse(row.endDate!),
      endAfterCount: row.endAfterCount,
      timeOfDay: row.timeOfDay,
      durationMinutes: row.durationMinutes,
      missedPolicy: MissedPolicy.values.byName(row.missedPolicy),
      scheduleMode: row.scheduleMode == 'rolling'
          ? ScheduleMode.rolling
          : ScheduleMode.fixed,
      pauseFrom: row.pauseFrom == null ? null : CivilDate.parse(row.pauseFrom!),
      pauseUntil: row.pauseUntil == null
          ? null
          : CivilDate.parse(row.pauseUntil!),
      goalId: row.goalId,
      notes: row.notes,
      generationVersion: row.generationVersion,
      archivedAt: row.archivedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.archivedAt!),
      createdAt: row.createdAt == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }

  List<AppOccurrence> _toOccurrenceList(List<db.PlanOccurrence> rows) =>
      rows.map(_toOccurrence).toList();

  AppOccurrence _toOccurrence(db.PlanOccurrence row) {
    return AppOccurrence(
      id: row.id,
      planId: row.planId,
      scheduledDate: CivilDate.parse(row.scheduledDate),
      scheduledTime: row.scheduledTime,
      originalDate: row.originalDate == null
          ? null
          : CivilDate.parse(row.originalDate!),
      status: OccurrenceStatus.values.byName(row.status),
      completedAt: row.completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
      valueAchieved: row.valueAchieved,
      linkedEntityType: row.linkedEntityType,
      linkedEntityId: row.linkedEntityId,
      note: row.note,
      isException: row.isException,
      generationVersion: row.generationVersion,
    );
  }
}
