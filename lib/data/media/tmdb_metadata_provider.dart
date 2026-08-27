import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/media/media_metadata_provider.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/tmdb_genres.dart';

/// §16.2. The API key is supplied per build via `--dart-define`, never
/// bundled — same pattern as Supabase's URL/anon key in
/// `supabase_client.dart`. Until a key is supplied, [isTmdbConfigured] is
/// false and every call fails with [ConfigurationFailure] rather than
/// pretending to search — no film list is ever bundled in the app (§16.2's
/// "never bundle a film list" rule) and manual add remains the fallback
/// (§16.7).
const _tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

bool get isTmdbConfigured => _tmdbApiKey.isNotEmpty;

/// TMDB's own required attribution (§16.2, non-negotiable): "This product
/// uses the TMDB API but is not endorsed or certified by TMDB." — shown
/// wherever TMDB-sourced results appear, plus their logo per their brand
/// guidelines.
const tmdbAttributionText =
    'This product uses the TMDB API but is not endorsed or certified by TMDB.';

/// The only `MediaMetadataProvider` implementation in v1 (§16.2) — nothing
/// outside `lib/data/media/` may import this class or reference a TMDB
/// response shape directly.
///
/// The constructor's `apiKey` defaults to the compile-time define but can
/// be overridden — purely so tests can inject a fake key alongside a fake
/// `client` without needing a real one; production call sites never pass
/// either.
class TmdbMetadataProvider implements MediaMetadataProvider, TvSeasonProvider {
  TmdbMetadataProvider({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? _tmdbApiKey;

  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const _maxAttempts = 3;

  final http.Client _client;
  final String _apiKey;

  @override
  String get providerId => 'tmdb';

  @override
  String get attributionText => tmdbAttributionText;

  @override
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<Result<List<MediaSearchResult>, Failure>> search(
    String query, {
    required MediaType type,
    int page = 1,
  }) async {
    if (!isConfigured) {
      return const Err(
        ConfigurationFailure(
          "TMDB isn't configured — add a search API key to enable this.",
        ),
      );
    }
    final path = type == MediaType.tv ? '/search/tv' : '/search/movie';
    final result = await _get(path, {'query': query, 'page': '$page'});
    return result.when(
      ok: (json) => Ok(_parseSearchResults(json, type)),
      err: Err.new,
    );
  }

  @override
  Future<Result<MediaDetail, Failure>> detail(
    String externalId,
    MediaType type,
  ) async {
    if (!isConfigured) {
      return const Err(
        ConfigurationFailure(
          "TMDB isn't configured — add a search API key to enable this.",
        ),
      );
    }
    final path = type == MediaType.tv
        ? '/tv/$externalId'
        : '/movie/$externalId';
    final result = await _get(path, {'append_to_response': 'credits'});
    return result.when(
      ok: (json) => Ok(_parseDetail(json, type)),
      err: Err.new,
    );
  }

  @override
  Future<Result<List<MediaSearchResult>, Failure>> trending({
    required MediaType type,
  }) async {
    if (!isConfigured) {
      return const Err(
        ConfigurationFailure(
          "TMDB isn't configured — add a search API key to enable this.",
        ),
      );
    }
    final path = type == MediaType.tv
        ? '/trending/tv/week'
        : '/trending/movie/week';
    final result = await _get(path, const {});
    return result.when(
      ok: (json) => Ok(_parseSearchResults(json, type)),
      err: Err.new,
    );
  }

  @override
  Future<Result<List<EpisodeSummary>, Failure>> seasonEpisodes(
    String showExternalId,
    int seasonNumber,
  ) async {
    if (!isConfigured) {
      return const Err(
        ConfigurationFailure(
          "TMDB isn't configured — add a search API key to enable this.",
        ),
      );
    }
    final result = await _get(
      '/tv/$showExternalId/season/$seasonNumber',
      const {},
    );
    return result.when(
      ok: (json) {
        final episodes = (json['episodes'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(
              (e) => EpisodeSummary(
                seasonNumber: e['season_number'] as int? ?? seasonNumber,
                episodeNumber: e['episode_number'] as int? ?? 0,
                title: e['name'] as String? ?? 'Episode ${e['episode_number']}',
                overview: _emptyToNull(e['overview'] as String?),
                airDate: e['air_date'] as String?,
                stillPath: e['still_path'] as String?,
              ),
            )
            .toList();
        return Ok(episodes);
      },
      err: Err.new,
    );
  }

  @override
  Uri imageUrl(String path, ImageSize size) {
    final sizeSegment = switch (size) {
      ImageSize.thumbnail => 'w92',
      ImageSize.small => 'w185',
      ImageSize.medium => 'w342',
      ImageSize.large => 'w500',
      ImageSize.original => 'original',
    };
    return Uri.parse('$_imageBaseUrl/$sizeSegment$path');
  }

  List<MediaSearchResult> _parseSearchResults(
    Map<String, dynamic> json,
    MediaType type,
  ) {
    final results = (json['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    return results.map((r) => _toSearchResult(r, type)).toList();
  }

  MediaSearchResult _toSearchResult(Map<String, dynamic> r, MediaType type) {
    final title =
        (type == MediaType.tv ? r['name'] : r['title']) as String? ??
        'Untitled';
    final dateString =
        (type == MediaType.tv ? r['first_air_date'] : r['release_date'])
            as String?;
    final genreIds = (r['genre_ids'] as List<dynamic>? ?? const []).cast<int>();
    return MediaSearchResult(
      externalId: '${r['id']}',
      title: title,
      year: _yearFrom(dateString),
      posterPath: r['poster_path'] as String?,
      overview: _emptyToNull(r['overview'] as String?),
      genres: type == MediaType.tv
          ? tmdbTvGenreNames(genreIds)
          : tmdbMovieGenreNames(genreIds),
    );
  }

  MediaDetail _parseDetail(Map<String, dynamic> json, MediaType type) {
    final title =
        (type == MediaType.tv ? json['name'] : json['title']) as String? ??
        'Untitled';
    final dateString =
        (type == MediaType.tv ? json['first_air_date'] : json['release_date'])
            as String?;
    final genres = (json['genres'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((g) => g['name'] as String? ?? '')
        .where((g) => g.isNotEmpty)
        .toList();
    final creators = type == MediaType.tv
        ? (json['created_by'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map((c) => c['name'] as String? ?? '')
              .where((c) => c.isNotEmpty)
              .toList()
        : _directorsFrom(json);
    final episodeRunTimes =
        (json['episode_run_time'] as List<dynamic>? ?? const []).cast<int>();
    final runtime = type == MediaType.tv
        ? (episodeRunTimes.isEmpty ? null : episodeRunTimes.first)
        : json['runtime'] as int?;
    return MediaDetail(
      externalId: '${json['id']}',
      mediaType: type,
      title: title,
      year: _yearFrom(dateString),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: _emptyToNull(json['overview'] as String?),
      runtimeMinutes: runtime,
      genres: genres,
      creators: creators,
      seasonCount: type == MediaType.tv
          ? json['number_of_seasons'] as int?
          : null,
    );
  }

  List<String> _directorsFrom(Map<String, dynamic> json) {
    final crew =
        ((json['credits'] as Map<String, dynamic>?)?['crew']
                    as List<dynamic>? ??
                const [])
            .cast<Map<String, dynamic>>();
    return crew
        .where((c) => c['job'] == 'Director')
        .map((c) => c['name'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toList();
  }

  int? _yearFrom(String? dateString) {
    if (dateString == null || dateString.length < 4) return null;
    return int.tryParse(dateString.substring(0, 4));
  }

  /// One retry helper for every call: exponential backoff on 429, up to
  /// [_maxAttempts] tries, matching §16.7's edge-case table exactly
  /// ("fail after 3 attempts with a retry button").
  Future<Result<Map<String, dynamic>, Failure>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: {...query, 'api_key': _apiKey});
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(uri)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 429) {
          if (attempt == _maxAttempts) {
            return const Err(
              NetworkFailure('TMDB rate limit exceeded', statusCode: 429),
            );
          }
          await Future<void>.delayed(
            Duration(milliseconds: 500 * (1 << attempt)),
          );
          continue;
        }
        if (response.statusCode != 200) {
          return Err(
            NetworkFailure(
              'TMDB returned ${response.statusCode}',
              statusCode: response.statusCode,
            ),
          );
        }
        return Ok(jsonDecode(response.body) as Map<String, dynamic>);
      } on TimeoutException {
        if (attempt == _maxAttempts) {
          return const Err(NetworkFailure('TMDB request timed out'));
        }
      } on Object catch (e) {
        if (attempt == _maxAttempts) {
          return Err(NetworkFailure('TMDB request failed: $e'));
        }
      }
    }
    return const Err(NetworkFailure('TMDB request failed'));
  }
}

String? _emptyToNull(String? value) =>
    (value == null || value.isEmpty) ? null : value;
