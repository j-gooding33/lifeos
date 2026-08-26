import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

void main() {
  late AppDatabase database;
  late PreferencesRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PreferencesRepository(PreferencesDao(database));
  });

  tearDown(() => database.close());

  test('get returns null for an unset key', () async {
    final result = await repository.get('user-1', 'reduceMotion');
    expect(result.when(ok: (v) => v, err: (_) => fail('unexpected')), isNull);
  });

  test('set then get round-trips', () async {
    final setResult = await repository.set('user-1', 'reduceMotion', 'true');
    expect(setResult.isOk, isTrue);

    final result = await repository.get('user-1', 'reduceMotion');
    expect(result.when(ok: (v) => v, err: (_) => fail('unexpected')), 'true');
  });

  test('set overwrites an existing value for the same key', () async {
    await repository.set('user-1', 'accent', 'signal');
    await repository.set('user-1', 'accent', 'pine');

    final result = await repository.get('user-1', 'accent');
    expect(result.when(ok: (v) => v, err: (_) => fail('unexpected')), 'pine');
  });

  test('keys are scoped per user', () async {
    await repository.set('user-1', 'accent', 'signal');
    final other = await repository.get('user-2', 'accent');
    expect(other.when(ok: (v) => v, err: (_) => fail('unexpected')), isNull);
  });
}
