import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/dashboard_card_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/dashboard_card_repository.dart';
import 'package:life_os/data/repositories/models/app_dashboard_card.dart';

void main() {
  late AppDatabase database;
  late DashboardCardRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DashboardCardRepository(DashboardCardDao(database));
  });

  tearDown(() => database.close());

  test("ensureDefaults materialises one row per catalog type, matching §5.3's default visible set", () async {
    await repository.ensureDefaults('u1');

    final cards = await repository.watchAll('u1').first;
    expect(cards.length, DashboardCardType.values.length);
    final visibleTypes = cards.where((c) => c.visible).map((c) => c.type).toSet();
    expect(visibleTypes, defaultVisibleDashboardCardTypes);
  });

  test('ensureDefaults is a no-op once rows already exist', () async {
    await repository.ensureDefaults('u1');
    final first = await repository.watchAll('u1').first;
    await repository.setVisible(first.first, visible: !first.first.visible);

    await repository.ensureDefaults('u1');

    final after = await repository.watchAll('u1').first;
    expect(after.first.visible, isNot(first.first.visible));
  });

  test('reorder persists new positions in the order given', () async {
    await repository.ensureDefaults('u1');
    final cards = await repository.watchAll('u1').first;
    final reversed = cards.reversed.toList();

    await repository.reorder(reversed);

    final after = await repository.watchAll('u1').first;
    expect(after.map((c) => c.type).toList(), reversed.map((c) => c.type).toList());
  });

  test('setVisible and setSize update just that card', () async {
    await repository.ensureDefaults('u1');
    final cards = await repository.watchAll('u1').first;
    final target = cards.first;

    await repository.setVisible(target, visible: false);
    await repository.setSize(target, DashboardCardSize.large);

    final after = (await repository.watchAll('u1').first).firstWhere((c) => c.id == target.id);
    expect(after.visible, isFalse);
    expect(after.size, DashboardCardSize.large);
  });

  test('resetToDefault discards customisation and restores the default visible set', () async {
    await repository.ensureDefaults('u1');
    final cards = await repository.watchAll('u1').first;
    await repository.setVisible(cards.first, visible: !cards.first.visible);

    await repository.resetToDefault('u1');

    final after = await repository.watchAll('u1').first;
    final visibleTypes = after.where((c) => c.visible).map((c) => c.type).toSet();
    expect(visibleTypes, defaultVisibleDashboardCardTypes);
  });

  test('dashboard cards are scoped per user', () async {
    await repository.ensureDefaults('u1');
    await repository.ensureDefaults('u2');

    final u1Cards = await repository.watchAll('u1').first;
    await repository.setVisible(u1Cards.first, visible: false);

    final u2Cards = await repository.watchAll('u2').first;
    expect(u2Cards.where((c) => c.type == u1Cards.first.type).single.visible, isTrue);
  });
}
