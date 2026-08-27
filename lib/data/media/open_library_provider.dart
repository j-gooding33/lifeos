import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/media/media_metadata_provider.dart';
import 'package:life_os/data/media/media_types.dart';

/// §16.2: "Books use the same pattern with `OpenLibraryProvider` (no key
/// required)." Open Library's search and cover-image APIs are public with
/// no registration, so this provider is always [isConfigured] — there's no
/// missing-key state for books the way there is for TMDB.
class OpenLibraryProvider implements MediaMetadataProvider {
  OpenLibraryProvider({http.Client? client})
    : _client = client ?? http.Client();

  static const _baseUrl = 'https://openlibrary.org';
  static const _coversBaseUrl = 'https://covers.openlibrary.org/b/id';

  final http.Client _client;

  @override
  String get providerId => 'openLibrary';

  @override
  String get attributionText => 'Book data from Open Library.';

  @override
  bool get isConfigured => true;

  @override
  Future<Result<List<MediaSearchResult>, Failure>> search(
    String query, {
    required MediaType type,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/search.json').replace(
      queryParameters: {
        'q': query,
        'page': '$page',
        'fields': 'key,title,author_name,first_publish_year,cover_i',
      },
    );
    final result = await _get(uri);
    return result.when(
      ok: (json) {
        final docs = (json['docs'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        return Ok(docs.map(_toSearchResult).toList());
      },
      err: Err.new,
    );
  }

  @override
  Future<Result<MediaDetail, Failure>> detail(
    String externalId,
    MediaType type,
  ) async {
    final uri = Uri.parse('$_baseUrl$externalId.json');
    final result = await _get(uri);
    return result.when(
      ok: (json) {
        final description = json['description'];
        final overview = switch (description) {
          final String s => s,
          final Map<String, dynamic> m => m['value'] as String?,
          _ => null,
        };
        final covers = (json['covers'] as List<dynamic>? ?? const [])
            .cast<int>();
        return Ok(
          MediaDetail(
            externalId: externalId,
            mediaType: MediaType.book,
            title: json['title'] as String? ?? 'Untitled',
            year: _yearFrom(json['first_publish_date'] as String?),
            posterPath: covers.isEmpty ? null : '${covers.first}',
            overview: overview,
            genres: (json['subjects'] as List<dynamic>? ?? const [])
                .cast<String>()
                .take(5)
                .toList(),
          ),
        );
      },
      err: Err.new,
    );
  }

  @override
  Future<Result<List<MediaSearchResult>, Failure>> trending({
    required MediaType type,
  }) async {
    final uri = Uri.parse('$_baseUrl/trending/daily.json');
    final result = await _get(uri);
    return result.when(
      ok: (json) {
        final works = (json['works'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        return Ok(works.map(_toSearchResult).toList());
      },
      // Trending is a nice-to-have for books, not load-bearing like
      // search — fail soft with an empty list rather than surfacing an
      // error for a secondary feature.
      err: (_) => const Ok([]),
    );
  }

  @override
  Uri imageUrl(String path, ImageSize size) {
    final sizeSegment = switch (size) {
      ImageSize.thumbnail || ImageSize.small => 'S',
      ImageSize.medium => 'M',
      ImageSize.large || ImageSize.original => 'L',
    };
    return Uri.parse('$_coversBaseUrl/$path-$sizeSegment.jpg');
  }

  MediaSearchResult _toSearchResult(Map<String, dynamic> doc) {
    final authors = (doc['author_name'] as List<dynamic>? ?? const [])
        .cast<String>();
    final coverId = doc['cover_i'] as int?;
    return MediaSearchResult(
      externalId: doc['key'] as String? ?? '',
      title: doc['title'] as String? ?? 'Untitled',
      year: doc['first_publish_year'] as int?,
      posterPath: coverId == null ? null : '$coverId',
      author: authors.isEmpty ? null : authors.join(', '),
    );
  }

  int? _yearFrom(String? dateString) {
    if (dateString == null || dateString.length < 4) return null;
    final match = RegExp(r'\d{4}').firstMatch(dateString);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  Future<Result<Map<String, dynamic>, Failure>> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        return Err(
          NetworkFailure(
            'Open Library returned ${response.statusCode}',
            statusCode: response.statusCode,
          ),
        );
      }
      return Ok(jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      return const Err(NetworkFailure('Open Library request timed out'));
    } on Object catch (e) {
      return Err(NetworkFailure('Open Library request failed: $e'));
    }
  }
}
