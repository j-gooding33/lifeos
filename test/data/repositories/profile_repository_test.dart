import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/profile_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_profile.dart';
import 'package:life_os/data/repositories/profile_repository.dart';

void main() {
  late AppDatabase database;
  late ProfileRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProfileRepository(ProfileDao(database));
  });

  tearDown(() => database.close());

  test('getProfile returns null before any save', () async {
    final result = await repository.getProfile('user-1');
    expect(result.when(ok: (v) => v, err: (_) => fail('unexpected')), isNull);
  });

  test('saveProfile then getProfile round-trips', () async {
    const profile = AppProfile(id: 'user-1', displayName: 'Sam');

    final saveResult = await repository.saveProfile(profile);
    expect(saveResult.isOk, isTrue);

    final fetched = await repository.getProfile('user-1');
    fetched.when(
      ok: (value) {
        expect(value?.displayName, 'Sam');
        expect(value?.currency, 'GBP');
      },
      err: (_) => fail('expected Ok'),
    );
  });

  test('watchProfile emits updates after a save', () async {
    final stream = repository.watchProfile('user-1');
    final events = <AppProfile?>[];
    final subscription = stream.listen(events.add);

    await repository.saveProfile(const AppProfile(id: 'user-1', displayName: 'Alex'));
    await Future<void>.delayed(Duration.zero);

    await subscription.cancel();
    expect(events.last?.displayName, 'Alex');
  });
}
