import 'package:drift/drift.dart';
import 'package:life_os/data/local/daos/dashboard_card_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_dashboard_card.dart';
import 'package:uuid/uuid.dart';

/// §5.3/§5.4. `focus` is deliberately absent from this table — "always
/// first, cannot be hidden or moved" means it isn't a row a user can
/// reorder or toggle, so `HomeScreen` renders it unconditionally instead.
class DashboardCardRepository {
  DashboardCardRepository(this._dao);

  final DashboardCardDao _dao;

  Stream<List<AppDashboardCard>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  /// Materialises one row per catalog type not already present for this
  /// user — the first time their dashboard is read (every type is
  /// "missing"), and again whenever the catalog itself grows (e.g.
  /// `filmNext` added after this user's rows already existed) — without
  /// ever touching an existing row's position/visibility/size.
  ///
  /// Also self-heals duplicate rows for the same type (keeping the one at
  /// the lowest position, deleting the rest): observed live where two
  /// overlapping calls — most plausibly two app processes briefly alive
  /// against the same database, or a hot-reload racing an in-flight call —
  /// each read "type X is missing" before either had inserted it, so both
  /// inserted it. The whole method runs in one transaction so a second,
  /// truly concurrent call on the *same* connection now blocks until the
  /// first commits, rather than interleaving with it — see DECISIONS.md.
  Future<void> ensureDefaults(String userId) => _dao.transaction(() async {
    final existing = await _dao.getAll(userId);
    final byType = <DashboardCardType, List<db.DashboardCard>>{};
    for (final row in existing) {
      (byType[DashboardCardType.values.byName(row.type)] ??= []).add(row);
    }
    for (final rows in byType.values) {
      if (rows.length <= 1) continue;
      rows.sort((a, b) => a.position.compareTo(b.position));
      for (final duplicate in rows.skip(1)) {
        await _dao.deleteById(duplicate.id);
      }
    }

    final missingTypes = dashboardCardTypeOrder.where((t) => !byType.containsKey(t));
    var nextPosition = existing.isEmpty ? 0 : existing.map((c) => c.position).reduce((a, b) => a > b ? a : b) + 1;
    for (final type in missingTypes) {
      await _save(
        AppDashboardCard(
          id: const Uuid().v4(),
          userId: userId,
          type: type,
          position: nextPosition++,
          visible: defaultVisibleDashboardCardTypes.contains(type),
        ),
      );
    }
  });

  Future<void> resetToDefault(String userId) => _dao.transaction(() async {
    await _dao.deleteAllForUser(userId);
    for (var i = 0; i < dashboardCardTypeOrder.length; i++) {
      final type = dashboardCardTypeOrder[i];
      await _save(
        AppDashboardCard(
          id: const Uuid().v4(),
          userId: userId,
          type: type,
          position: i,
          visible: defaultVisibleDashboardCardTypes.contains(type),
        ),
      );
    }
  });

  Future<void> reorder(List<AppDashboardCard> orderedCards) async {
    for (var i = 0; i < orderedCards.length; i++) {
      await _save(orderedCards[i].copyWith(position: i));
    }
  }

  Future<void> setVisible(AppDashboardCard card, {required bool visible}) => _dao.patch(
    card.id,
    db.DashboardCardsCompanion(visible: Value(visible), updatedAt: Value(DateTime.now().millisecondsSinceEpoch)),
  );

  Future<void> setSize(AppDashboardCard card, DashboardCardSize size) => _dao.patch(
    card.id,
    db.DashboardCardsCompanion(size: Value(size.name), updatedAt: Value(DateTime.now().millisecondsSinceEpoch)),
  );

  Future<void> _save(AppDashboardCard card) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.DashboardCardsCompanion(
        id: Value(card.id),
        userId: Value(card.userId),
        type: Value(card.type.name),
        position: Value(card.position),
        visible: Value(card.visible),
        size: Value(card.size.name),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppDashboardCard> _toDomainList(List<db.DashboardCard> rows) => rows.map(_toDomain).toList();

  AppDashboardCard _toDomain(db.DashboardCard row) {
    return AppDashboardCard(
      id: row.id,
      userId: row.userId,
      type: DashboardCardType.values.byName(row.type),
      position: row.position,
      visible: row.visible,
      size: DashboardCardSize.values.byName(row.size),
    );
  }
}
