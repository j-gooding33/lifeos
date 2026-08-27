import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/open_library_provider.dart';
import 'package:test/test.dart';

/// A genuine call against the real Open Library API — tagged `live` and
/// excluded from the standard suite (`ci.yaml` runs `flutter test
/// --exclude-tags=live`) so a flaky network or an Open Library outage
/// never breaks CI. Uses `package:test` rather than `package:flutter_test`
/// deliberately: `flutter_test`'s binding intercepts every `HttpClient`
/// and forces a 400 on any real request, which would defeat the point of
/// this file. Open Library needs no API key (§16.2), so this is the one
/// provider this session can verify live; run explicitly with:
///   dart test test/data/media/open_library_provider_live_test.dart
void main() {
  test('search("dune") returns real results from the live API', () async {
    final provider = OpenLibraryProvider();
    final result = await provider.search('dune', type: MediaType.book);
    final results = result.when(
      ok: (r) => r,
      err: (f) => throw StateError('live call failed: ${f.message}'),
    );

    expect(results, isNotEmpty);
    expect(results.first.title, isNotEmpty);
  }, tags: 'live');
}
