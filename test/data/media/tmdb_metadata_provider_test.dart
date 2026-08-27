import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';

import 'fake_http_client.dart';

void main() {
  test(
    'a provider with no API key reports unconfigured and fails every call',
    () async {
      final provider = TmdbMetadataProvider(
        client: FakeHttpClient((_) => jsonResponse({})),
        apiKey: '',
      );
      expect(provider.isConfigured, isFalse);

      final result = await provider.search('dune', type: MediaType.film);
      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<ConfigurationFailure>()),
      );
    },
  );

  test(
    'search(film) parses title, year, poster and maps genre ids to names',
    () async {
      final client = FakeHttpClient(
        (uri) => jsonResponse({
          'results': [
            {
              'id': 157336,
              'title': 'Interstellar',
              'release_date': '2014-11-05',
              'poster_path': '/poster.jpg',
              'overview': 'A team of explorers...',
              'genre_ids': [878, 18],
            },
          ],
        }),
      );
      final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

      final result = await provider.search(
        'interstellar',
        type: MediaType.film,
      );
      final results = result.when(
        ok: (r) => r,
        err: (f) => throw StateError('expected Ok, got ${f.message}'),
      );

      expect(results, hasLength(1));
      expect(results.first.externalId, '157336');
      expect(results.first.title, 'Interstellar');
      expect(results.first.year, 2014);
      expect(results.first.posterPath, '/poster.jpg');
      expect(results.first.genres, ['Sci-Fi', 'Drama']);
      expect(client.requestedUris.single.path, '/3/search/movie');
    },
  );

  test('search(tv) reads "name" and "first_air_date" instead of the film field names', () async {
    final client = FakeHttpClient(
      (uri) => jsonResponse({
        'results': [
          {
            'id': 1396,
            'name': 'Breaking Bad',
            'first_air_date': '2008-01-20',
            'poster_path': '/bb.jpg',
            'genre_ids': [18],
          },
        ],
      }),
    );
    final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

    final result = await provider.search('breaking bad', type: MediaType.tv);
    final results = result.when(
      ok: (r) => r,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(results.single.title, 'Breaking Bad');
    expect(results.single.year, 2008);
    expect(results.single.genres, ['Drama']);
    expect(client.requestedUris.single.path, '/3/search/tv');
  });

  test('detail(film) extracts runtime, genre names directly, and the director from credits', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'id': 157336,
        'title': 'Interstellar',
        'release_date': '2014-11-05',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'overview': 'A team of explorers...',
        'runtime': 169,
        'genres': [
          {'id': 878, 'name': 'Science Fiction'},
        ],
        'credits': {
          'crew': [
            {'job': 'Director', 'name': 'Christopher Nolan'},
            {'job': 'Writer', 'name': 'Jonathan Nolan'},
          ],
        },
      }),
    );
    final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

    final result = await provider.detail('157336', MediaType.film);
    final detail = result.when(
      ok: (d) => d,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(detail.runtimeMinutes, 169);
    expect(detail.genres, ['Science Fiction']);
    expect(detail.creators, ['Christopher Nolan']);
    expect(detail.seasonCount, isNull);
  });

  test('detail(tv) reads creators from created_by and runtime from episode_run_time', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'id': 1396,
        'name': 'Breaking Bad',
        'first_air_date': '2008-01-20',
        'episode_run_time': [47],
        'genres': [
          {'id': 18, 'name': 'Drama'},
        ],
        'created_by': [
          {'name': 'Vince Gilligan'},
        ],
        'number_of_seasons': 5,
      }),
    );
    final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

    final result = await provider.detail('1396', MediaType.tv);
    final detail = result.when(
      ok: (d) => d,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(detail.runtimeMinutes, 47);
    expect(detail.creators, ['Vince Gilligan']);
    expect(detail.seasonCount, 5);
  });

  test('seasonEpisodes parses each episode, falling back to a title when name is missing', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'episodes': [
          {
            'season_number': 1,
            'episode_number': 1,
            'name': 'Pilot',
            'overview': 'The one where it all begins.',
            'air_date': '2008-01-20',
            'still_path': '/still1.jpg',
          },
          {
            'season_number': 1,
            'episode_number': 2,
            'name': '',
            'air_date': null,
          },
        ],
      }),
    );
    final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

    final result = await provider.seasonEpisodes('1396', 1);
    final episodes = result.when(
      ok: (e) => e,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(episodes, hasLength(2));
    expect(episodes.first.title, 'Pilot');
    expect(episodes.first.airDate, '2008-01-20');
    expect(episodes.last.airDate, isNull);
  });

  test('imageUrl builds the correct TMDB CDN path for each size', () {
    final provider = TmdbMetadataProvider(apiKey: 'test-key');
    expect(
      provider.imageUrl('/poster.jpg', ImageSize.large).toString(),
      'https://image.tmdb.org/t/p/w500/poster.jpg',
    );
    expect(
      provider.imageUrl('/poster.jpg', ImageSize.original).toString(),
      'https://image.tmdb.org/t/p/original/poster.jpg',
    );
  });

  test(
    'a non-200 response maps to NetworkFailure with the status code',
    () async {
      final client = FakeHttpClient(
        (_) => jsonResponse({'status_message': 'Not found'}, statusCode: 404),
      );
      final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

      final result = await provider.detail('nope', MediaType.film);
      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) {
          expect(failure, isA<NetworkFailure>());
          expect((failure as NetworkFailure).statusCode, 404);
        },
      );
    },
  );

  test('a missing poster/overview is null, not a crash (§16.7)', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'results': [
          {
            'id': 1,
            'title': 'No Poster Movie',
            'release_date': '',
            'genre_ids': <int>[],
          },
        ],
      }),
    );
    final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

    final result = await provider.search('x', type: MediaType.film);
    final results = result.when(
      ok: (r) => r,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(results.single.posterPath, isNull);
    expect(results.single.year, isNull);
    expect(results.single.overview, isNull);
  });

  test(
    '429 responses retry with backoff and eventually fail as rate-limited',
    () async {
      var attempts = 0;
      final client = FakeHttpClient((_) {
        attempts++;
        return jsonResponse({
          'status_message': 'Rate limited',
        }, statusCode: 429);
      });
      final provider = TmdbMetadataProvider(client: client, apiKey: 'test-key');

      final result = await provider.detail('1', MediaType.film);
      expect(attempts, 3);
      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) {
          expect(failure, isA<NetworkFailure>());
          expect((failure as NetworkFailure).isRateLimited, isTrue);
        },
      );
    },
  );
}
