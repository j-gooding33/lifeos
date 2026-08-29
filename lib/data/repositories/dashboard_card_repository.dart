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

  /// Materialises one row per catalog type the first time a user's
  /// dashboard is read, so the customise screen always has every type to
  /// toggle on — not just the ones already visible.
  Future<void> ensureDefaults(String userId) async {
    final existing = await _dao.getAll(userId);
    if (existing.isNotEmpty) return;
    await resetToDefault(userId);
  }

  Future<void> resetToDefault(String userId) async {
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
  }

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
