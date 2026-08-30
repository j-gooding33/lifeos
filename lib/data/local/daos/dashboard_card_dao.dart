import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/dashboard_cards_table.dart';

part 'dashboard_card_dao.g.dart';

@DriftAccessor(tables: [DashboardCards])
class DashboardCardDao extends DatabaseAccessor<AppDatabase> with _$DashboardCardDaoMixin {
  DashboardCardDao(super.db);

  Stream<List<DashboardCard>> watchAll(String userId) {
    final query = select(dashboardCards)
      ..where((c) => c.userId.equals(userId))
      ..orderBy([(c) => OrderingTerm.asc(c.position)]);
    return query.watch();
  }

  Future<List<DashboardCard>> getAll(String userId) {
    final query = select(dashboardCards)
      ..where((c) => c.userId.equals(userId))
      ..orderBy([(c) => OrderingTerm.asc(c.position)]);
    return query.get();
  }

  Future<void> upsert(DashboardCardsCompanion entry) => into(dashboardCards).insertOnConflictUpdate(entry);

  /// A targeted column update, not a full-row upsert — `update(...).write`
  /// only touches the columns actually set on [patch], so calling this
  /// twice in a row (e.g. setVisible then setSize) can never let the
  /// second call's caller-held, now-stale snapshot clobber the first.
  Future<void> patch(String id, DashboardCardsCompanion patch) =>
      (update(dashboardCards)..where((c) => c.id.equals(id))).write(patch);

  Future<void> deleteAllForUser(String userId) => (delete(dashboardCards)..where((c) => c.userId.equals(userId))).go();

  Future<void> deleteById(String id) => (delete(dashboardCards)..where((c) => c.id.equals(id))).go();
}
