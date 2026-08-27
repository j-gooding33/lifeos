import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/ai_permissions_repository.dart';
import 'package:life_os/data/repositories/models/ai_permission_scopes.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

void main() {
  late AppDatabase database;
  late AiPermissionsRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AiPermissionsRepository(PreferencesRepository(PreferencesDao(database)));
  });

  tearDown(() => database.close());

  test('defaults are off for the assistant and journal/finance, on for everything else', () async {
    final scopes = await repository.watch('u1').first;
    expect(scopes.enabled, isFalse);
    expect(scopes.canWrite, isTrue);
    expect(scopes.tasks, isTrue);
    expect(scopes.journal, isFalse);
    expect(scopes.finance, isFalse);
  });

  test('save then watch round-trips every field', () async {
    const scopes = AiPermissionScopes(enabled: true, canWrite: false, journal: true, finance: true, tasks: false);
    await repository.save('u1', scopes);

    final loaded = await repository.watch('u1').first;
    expect(loaded.enabled, isTrue);
    expect(loaded.canWrite, isFalse);
    expect(loaded.journal, isTrue);
    expect(loaded.finance, isTrue);
    expect(loaded.tasks, isFalse);
    expect(loaded.plans, isTrue);
  });

  test('scopes are isolated per user', () async {
    await repository.save('u1', const AiPermissionScopes(enabled: true));
    final other = await repository.watch('u2').first;
    expect(other.enabled, isFalse);
  });

  test('copyWith only changes the given fields', () async {
    const scopes = AiPermissionScopes();
    final next = scopes.copyWith(enabled: true, journal: true);
    expect(next.enabled, isTrue);
    expect(next.journal, isTrue);
    expect(next.canWrite, scopes.canWrite);
    expect(next.tasks, scopes.tasks);
  });
}
