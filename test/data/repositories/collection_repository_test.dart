import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/collection_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/collection_repository.dart';
import 'package:life_os/data/repositories/models/app_collection.dart';

void main() {
  late AppDatabase database;
  late CollectionRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepository(CollectionDao(database));
  });

  tearDown(() => database.close());

  test('create then watchAll round-trips a collection', () async {
    final created = await repository.create(userId: 'u1', title: 'Cosy autumn watches');
    expect(created.isOk, isTrue);

    final all = await repository.watchAll('u1').first;
    expect(all, hasLength(1));
    expect(all.single.title, 'Cosy autumn watches');
    expect(all.single.itemType, isNull);
  });

  test('create with an itemType round-trips it', () async {
    await repository.create(userId: 'u1', title: 'Best sci-fi films', itemType: MediaType.film);

    final all = await repository.watchAll('u1').first;
    expect(all.single.itemType, MediaType.film);
  });

  test("watchAll only returns the given user's collections", () async {
    await repository.create(userId: 'u1', title: 'Mine');
    await repository.create(userId: 'u2', title: 'Not mine');

    final all = await repository.watchAll('u1').first;
    expect(all.map((c) => c.title), ['Mine']);
  });

  test('rename updates the title', () async {
    final created = (await repository.create(userId: 'u1', title: 'Old title') as Ok<AppCollection, Failure>).value;
    await repository.rename(created.id, 'New title');

    final loaded = await repository.watchById(created.id).first;
    expect(loaded!.title, 'New title');
  });

  test('delete is a soft delete: it disappears from watchAll and watchById', () async {
    final created = (await repository.create(userId: 'u1', title: 'Temporary') as Ok<AppCollection, Failure>).value;
    await repository.delete(created.id);

    expect(await repository.watchAll('u1').first, isEmpty);
    expect(await repository.watchById(created.id).first, isNull);
  });

  test('addItem then watchItemIds round-trips, and removeItem removes it', () async {
    final created = (await repository.create(userId: 'u1', title: 'Favourites') as Ok<AppCollection, Failure>).value;
    await repository.addItem(created.id, 'film1');
    await repository.addItem(created.id, 'book1');

    var ids = await repository.watchItemIds(created.id).first;
    expect(ids, containsAll(['film1', 'book1']));

    await repository.removeItem(created.id, 'film1');
    ids = await repository.watchItemIds(created.id).first;
    expect(ids, ['book1']);
  });

  test('watchCollectionIdsContaining finds every collection an item belongs to', () async {
    final a = (await repository.create(userId: 'u1', title: 'A') as Ok<AppCollection, Failure>).value;
    final b = (await repository.create(userId: 'u1', title: 'B') as Ok<AppCollection, Failure>).value;
    await repository.addItem(a.id, 'film1');
    await repository.addItem(b.id, 'film1');

    final memberOf = await repository.watchCollectionIdsContaining('film1').first;
    expect(memberOf, {a.id, b.id});
    expect(await repository.watchCollectionIdsContaining('film2').first, isEmpty);
  });
}
