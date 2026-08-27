import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/tv_episode_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/tv_episode_repository.dart';

void main() {
  late AppDatabase database;
  late TvEpisodeRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TvEpisodeRepository(TvEpisodeDao(database));
  });

  tearDown(() => database.close());

  const episodes = [
    EpisodeSummary(
      seasonNumber: 1,
      episodeNumber: 1,
      title: 'Pilot',
      airDate: '2008-01-20',
    ),
    EpisodeSummary(
      seasonNumber: 1,
      episodeNumber: 2,
      title: "Cat's in the Bag...",
      airDate: '2008-01-27',
    ),
  ];

  test('importing a season creates one row per episode', () async {
    await repository.importSeason(
      userId: 'u1',
      libraryItemId: 'show1',
      episodes: episodes,
    );
    final all = await repository.watchForShow('show1').first;
    expect(all, hasLength(2));
    expect(all.map((e) => e.title), ['Pilot', "Cat's in the Bag..."]);
  });

  test(
    're-importing a season never overwrites existing watched/rating/log state',
    () async {
      await repository.importSeason(
        userId: 'u1',
        libraryItemId: 'show1',
        episodes: episodes,
      );
      final pilot = (await repository.watchForShow('show1').first).first;
      await repository.markWatched(pilot.id, watchedDate: DateTime(2026));
      await repository.setRating(pilot.id, 6);
      await repository.setLog(pilot.id, 'Great start.');

      // Re-import (e.g. the provider refreshed metadata).
      await repository.importSeason(
        userId: 'u1',
        libraryItemId: 'show1',
        episodes: episodes,
      );

      final reimported = (await repository.watchForShow('show1').first)
          .firstWhere((e) => e.id == pilot.id);
      expect(reimported.isWatched, isTrue);
      expect(reimported.rating, 6);
      expect(reimported.log, 'Great start.');
    },
  );

  test(
    'a 6-star rating marks the episode a personal favourite, not "6 of 5"',
    () async {
      await repository.importSeason(
        userId: 'u1',
        libraryItemId: 'show1',
        episodes: episodes,
      );
      final pilot = (await repository.watchForShow('show1').first).first;

      await repository.setRating(pilot.id, 6);
      final rated = (await repository.watchForShow('show1').first).firstWhere(
        (e) => e.id == pilot.id,
      );
      expect(rated.isPersonalFavourite, isTrue);

      await repository.setRating(pilot.id, 5);
      final fiveStars = (await repository.watchForShow('show1').first)
          .firstWhere((e) => e.id == pilot.id);
      expect(fiveStars.isPersonalFavourite, isFalse);
    },
  );

  test(
    'marking unwatched clears the watched date but keeps rating and log',
    () async {
      await repository.importSeason(
        userId: 'u1',
        libraryItemId: 'show1',
        episodes: episodes,
      );
      final pilot = (await repository.watchForShow('show1').first).first;
      await repository.markWatched(pilot.id, watchedDate: DateTime(2026));
      await repository.setRating(pilot.id, 5);

      await repository.markUnwatched(pilot.id);

      final updated = (await repository.watchForShow('show1').first).firstWhere(
        (e) => e.id == pilot.id,
      );
      expect(updated.isWatched, isFalse);
      expect(updated.rating, 5);
    },
  );

  test('watchForSeason filters to just that season', () async {
    await repository.importSeason(
      userId: 'u1',
      libraryItemId: 'show1',
      episodes: episodes,
    );
    await repository.importSeason(
      userId: 'u1',
      libraryItemId: 'show1',
      episodes: const [
        EpisodeSummary(seasonNumber: 2, episodeNumber: 1, title: 'S2E1'),
      ],
    );

    final season1 = await repository.watchForSeason('show1', 1).first;
    expect(season1, hasLength(2));
    final season2 = await repository.watchForSeason('show1', 2).first;
    expect(season2, hasLength(1));
  });

  test('watchRated only includes rated episodes, across shows', () async {
    await repository.importSeason(
      userId: 'u1',
      libraryItemId: 'show1',
      episodes: episodes,
    );
    final all = await repository.watchForShow('show1').first;
    await repository.setRating(all.first.id, 4);

    final rated = await repository.watchRated('u1').first;
    expect(rated, hasLength(1));
    expect(rated.single.id, all.first.id);
  });
}
