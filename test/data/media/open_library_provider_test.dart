import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/open_library_provider.dart';

import 'fake_http_client.dart';

void main() {
  test('is always configured — no API key needed for books (§16.2)', () {
    expect(OpenLibraryProvider().isConfigured, isTrue);
  });

  test('search parses title, author, year and cover id', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'docs': [
          {
            'key': '/works/OL27448W',
            'title': 'Dune',
            'author_name': ['Frank Herbert'],
            'first_publish_year': 1965,
            'cover_i': 12345,
          },
        ],
      }),
    );
    final provider = OpenLibraryProvider(client: client);

    final result = await provider.search('dune', type: MediaType.book);
    final results = result.when(
      ok: (r) => r,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(results.single.externalId, '/works/OL27448W');
    expect(results.single.title, 'Dune');
    expect(results.single.author, 'Frank Herbert');
    expect(results.single.year, 1965);
    expect(results.single.posterPath, '12345');
  });

  test('search joins multiple authors and tolerates a missing cover', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'docs': [
          {
            'key': '/works/OL1W',
            'title': 'Good Omens',
            'author_name': ['Terry Pratchett', 'Neil Gaiman'],
          },
        ],
      }),
    );
    final provider = OpenLibraryProvider(client: client);

    final result = await provider.search('good omens', type: MediaType.book);
    final results = result.when(
      ok: (r) => r,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(results.single.author, 'Terry Pratchett, Neil Gaiman');
    expect(results.single.posterPath, isNull);
  });

  test('detail reads a plain-string description', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'title': 'Dune',
        'description': 'A science fiction novel.',
        'covers': [12345],
        'first_publish_date': '1965',
        'subjects': ['Science fiction', 'Adventure'],
      }),
    );
    final provider = OpenLibraryProvider(client: client);

    final result = await provider.detail('/works/OL27448W', MediaType.book);
    final detail = result.when(
      ok: (d) => d,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(detail.overview, 'A science fiction novel.');
    expect(detail.year, 1965);
    expect(detail.genres, ['Science fiction', 'Adventure']);
  });

  test('detail reads a {value: ...}-shaped description', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({
        'title': 'Dune',
        'description': {
          'type': '/type/text',
          'value': 'A science fiction novel.',
        },
      }),
    );
    final provider = OpenLibraryProvider(client: client);

    final result = await provider.detail('/works/OL27448W', MediaType.book);
    final detail = result.when(
      ok: (d) => d,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(detail.overview, 'A science fiction novel.');
  });

  test('a missing cover/description is null, not a crash (§16.7)', () async {
    final client = FakeHttpClient(
      (_) => jsonResponse({'title': 'Mystery Book'}),
    );
    final provider = OpenLibraryProvider(client: client);

    final result = await provider.detail('/works/OLxW', MediaType.book);
    final detail = result.when(
      ok: (d) => d,
      err: (f) => throw StateError('expected Ok, got ${f.message}'),
    );

    expect(detail.posterPath, isNull);
    expect(detail.overview, isNull);
    expect(detail.genres, isEmpty);
  });

  test(
    'trending fails soft to an empty list rather than surfacing an error',
    () async {
      final client = FakeHttpClient(
        (_) => jsonResponse({'error': 'nope'}, statusCode: 500),
      );
      final provider = OpenLibraryProvider(client: client);

      final result = await provider.trending(type: MediaType.book);
      final results = result.when(
        ok: (r) => r,
        err: (f) => throw StateError('expected Ok even on failure'),
      );
      expect(results, isEmpty);
    },
  );

  test(
    'search still returns NetworkFailure on error (unlike trending)',
    () async {
      final client = FakeHttpClient(
        (_) => jsonResponse({'error': 'nope'}, statusCode: 500),
      );
      final provider = OpenLibraryProvider(client: client);

      final result = await provider.search('x', type: MediaType.book);
      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<NetworkFailure>()),
      );
    },
  );

  test('imageUrl builds the Open Library covers CDN path', () {
    final provider = OpenLibraryProvider();
    expect(
      provider.imageUrl('12345', ImageSize.large).toString(),
      'https://covers.openlibrary.org/b/id/12345-L.jpg',
    );
    expect(
      provider.imageUrl('12345', ImageSize.thumbnail).toString(),
      'https://covers.openlibrary.org/b/id/12345-S.jpg',
    );
  });
}
