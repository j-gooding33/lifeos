import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/plan_occurrences_table.dart';
import 'package:life_os/data/local/tables/plans_table.dart';

part 'plan_dao.g.dart';

@DriftAccessor(tables: [Plans, PlanOccurrences])
class PlanDao extends DatabaseAccessor<AppDatabase> with _$PlanDaoMixin {
  PlanDao(super.db);

  Stream<List<Plan>> watchActive(String userId, String today) {
    final query = select(plans)
      ..where(
        (p) =>
            p.userId.equals(userId) &
            p.deletedAt.isNull() &
            p.archivedAt.isNull() &
            p.kind.equals('plan') &
            _notPausedOn(p, today),
      )
      ..orderBy([(p) => OrderingTerm.asc(p.sortIndex)]);
    return query.watch();
  }

  /// §12.3's "linked plans" list on a goal's detail screen.
  Stream<List<Plan>> watchByGoalId(String goalId) {
    final query = select(plans)
      ..where((p) => p.goalId.equals(goalId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.asc(p.sortIndex)]);
    return query.watch();
  }

  Stream<List<Plan>> watchHabits(String userId) {
    final query = select(plans)
      ..where(
        (p) =>
            p.userId.equals(userId) &
            p.deletedAt.isNull() &
            p.archivedAt.isNull() &
            p.kind.equals('habit'),
      )
      ..orderBy([(p) => OrderingTerm.asc(p.sortIndex)]);
    return query.watch();
  }

  Stream<List<Plan>> watchPaused(String userId, String today) {
    final query = select(plans)
      ..where(
        (p) =>
            p.userId.equals(userId) &
            p.deletedAt.isNull() &
            p.archivedAt.isNull() &
            p.kind.equals('plan') &
            p.pauseFrom.isSmallerOrEqualValue(today) &
            p.pauseUntil.isBiggerOrEqualValue(today),
      )
      ..orderBy([(p) => OrderingTerm.asc(p.sortIndex)]);
    return query.watch();
  }

  Stream<List<Plan>> watchArchived(String userId) {
    final query = select(plans)
      ..where(
        (p) =>
            p.userId.equals(userId) &
            p.deletedAt.isNull() &
            p.archivedAt.isNotNull(),
      )
      ..orderBy([(p) => OrderingTerm.desc(p.archivedAt)]);
    return query.watch();
  }

  Expression<bool> _notPausedOn(Plans p, String today) {
    return p.pauseFrom.isNull() |
        p.pauseUntil.isNull() |
        p.pauseUntil.isSmallerThanValue(today);
  }

  Future<Plan?> getById(String id) =>
      (select(plans)..where((p) => p.id.equals(id))).getSingleOrNull();

  Stream<Plan?> watchById(String id) =>
      (select(plans)..where((p) => p.id.equals(id))).watchSingleOrNull();

  Future<void> upsert(PlansCompanion entry) =>
      into(plans).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(plans)..where((p) => p.id.equals(id))).write(
        PlansCompanion(deletedAt: Value(now)),
      );

  Future<void> setArchivedAt(String id, int? archivedAtMs, int now) =>
      (update(plans)..where((p) => p.id.equals(id))).write(
        PlansCompanion(archivedAt: Value(archivedAtMs), updatedAt: Value(now)),
      );

  Future<List<PlanOccurrence>> getOccurrencesForPlan(String planId) {
    return (select(
      planOccurrences,
    )..where((o) => o.planId.equals(planId))).get();
  }

  /// Unbounded (fine — capped at `Materialiser.maxOccurrencesPerPlan`), used
  /// to compute §7.5's stats strip and heatmap reactively.
  Stream<List<PlanOccurrence>> watchAllForPlan(String planId) {
    return (select(
      planOccurrences,
    )..where((o) => o.planId.equals(planId))).watch();
  }

  Stream<List<PlanOccurrence>> watchUpcoming(
    String planId,
    String afterDate, {
    int limit = 30,
  }) {
    final query = select(planOccurrences)
      ..where(
        (o) =>
            o.planId.equals(planId) &
            o.scheduledDate.isBiggerThanValue(afterDate),
      )
      ..orderBy([(o) => OrderingTerm.asc(o.scheduledDate)])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<PlanOccurrence>> watchHistory(
    String planId,
    String throughDate, {
    int limit = 20,
  }) {
    final query = select(planOccurrences)
      ..where(
        (o) =>
            o.planId.equals(planId) &
            o.scheduledDate.isSmallerOrEqualValue(throughDate),
      )
      ..orderBy([(o) => OrderingTerm.desc(o.scheduledDate)])
      ..limit(limit);
    return query.watch();
  }

  /// One range query per visible period (§14.5) — used by both the
  /// single-plan calendar and the unified calendar's month/week/day views.
  Stream<List<PlanOccurrence>> watchOccurrencesInRange(
    String userId,
    String from,
    String through,
  ) {
    final query = select(planOccurrences)
      ..where(
        (o) =>
            o.userId.equals(userId) &
            o.scheduledDate.isBiggerOrEqualValue(from) &
            o.scheduledDate.isSmallerOrEqualValue(through),
      )
      ..orderBy([(o) => OrderingTerm.asc(o.scheduledDate)]);
    return query.watch();
  }

  Stream<List<PlanOccurrence>> watchOccurrencesInRangeForPlan(
    String planId,
    String from,
    String through,
  ) {
    final query = select(planOccurrences)
      ..where(
        (o) =>
            o.planId.equals(planId) &
            o.scheduledDate.isBiggerOrEqualValue(from) &
            o.scheduledDate.isSmallerOrEqualValue(through),
      )
      ..orderBy([(o) => OrderingTerm.asc(o.scheduledDate)]);
    return query.watch();
  }

  Stream<PlanOccurrence?> watchOccurrenceById(String id) => (select(
    planOccurrences,
  )..where((o) => o.id.equals(id))).watchSingleOrNull();

  /// The §7.4 list row's right-hand state needs "is there an occurrence
  /// due today, and is it done" per plan.
  Stream<PlanOccurrence?> watchOccurrenceOnDate(String planId, String date) {
    return (select(
          planOccurrences,
        )..where((o) => o.planId.equals(planId) & o.scheduledDate.equals(date)))
        .watchSingleOrNull();
  }

  /// One-shot version of [watchOccurrenceOnDate] — §8.4 point 4's conflict
  /// check needs a single read, not a subscription.
  Future<PlanOccurrence?> getOccurrenceOnDate(String planId, String date) {
    return (select(
          planOccurrences,
        )..where((o) => o.planId.equals(planId) & o.scheduledDate.equals(date)))
        .getSingleOrNull();
  }

  Future<void> upsertOccurrence(PlanOccurrencesCompanion entry) =>
      into(planOccurrences).insertOnConflictUpdate(entry);

  Future<void> deleteOccurrence(String id) =>
      (delete(planOccurrences)..where((o) => o.id.equals(id))).go();

  Future<void> updateOccurrenceStatus(
    String id, {
    required String status,
    String? scheduledDate,
    int? completedAt,
    bool clearCompletedAt = false,
    bool? isException,
  }) {
    return (update(planOccurrences)..where((o) => o.id.equals(id))).write(
      PlanOccurrencesCompanion(
        status: Value(status),
        scheduledDate: scheduledDate == null
            ? const Value.absent()
            : Value(scheduledDate),
        completedAt: clearCompletedAt
            ? const Value(null)
            : (completedAt == null ? const Value.absent() : Value(completedAt)),
        isException: isException == null
            ? const Value.absent()
            : Value(isException),
      ),
    );
  }

  Future<void> setOccurrenceNote(String id, String? note) {
    return (update(planOccurrences)..where((o) => o.id.equals(id))).write(
      PlanOccurrencesCompanion(note: Value(note)),
    );
  }

  /// §16.5's "choose a film"/"unlink" — pass both null to unlink.
  Future<void> setLinkedEntity(
    String id, {
    String? entityType,
    String? entityId,
  }) {
    return (update(planOccurrences)..where((o) => o.id.equals(id))).write(
      PlanOccurrencesCompanion(
        linkedEntityType: Value(entityType),
        linkedEntityId: Value(entityId),
      ),
    );
  }

  /// §8.4 step 1: the move itself — sets `originalDate`, the new
  /// `scheduledDate`, `isException = true`, and `status = pending`.
  Future<void> moveOccurrence(
    String id, {
    required String originalDate,
    required String newDate,
  }) {
    return (update(planOccurrences)..where((o) => o.id.equals(id))).write(
      PlanOccurrencesCompanion(
        originalDate: Value(originalDate),
        scheduledDate: Value(newDate),
        isException: const Value(true),
        status: const Value('pending'),
      ),
    );
  }
}
