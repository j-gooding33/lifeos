import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/media/media_types.dart';

/// §16.2: the boundary that makes the metadata provider replaceable.
/// Nothing outside `lib/data/media/` may reference a provider's own types
/// (TMDB response shapes, Open Library response shapes) — everything here
/// is `Result`-wrapped rather than the spec's bare `Future`, to match this
/// codebase's established repository error-handling convention (see
/// DECISIONS.md).
abstract class MediaMetadataProvider {
  /// `'tmdb'`, `'openLibrary'`.
  String get providerId;

  /// Required attribution text (§16.2's TMDB legal requirement) — shown on
  /// the search screen and in Settings → About whenever this provider is
  /// active for a given [MediaType].
  String get attributionText;

  bool get isConfigured;

  Future<Result<List<MediaSearchResult>, Failure>> search(
    String query, {
    required MediaType type,
    int page = 1,
  });

  Future<Result<MediaDetail, Failure>> detail(
    String externalId,
    MediaType type,
  );

  Future<Result<List<MediaSearchResult>, Failure>> trending({
    required MediaType type,
  });

  Uri imageUrl(String path, ImageSize size);
}

/// TV-only capability: season/episode listing. A separate interface rather
/// than a method on [MediaMetadataProvider] itself — Open Library has no
/// notion of seasons, and a provider shouldn't have to pretend to support
/// capabilities that don't apply to it. A capability marker checked via
/// `is TvSeasonProvider`, not a candidate for a top-level function.
// ignore: one_member_abstracts
abstract class TvSeasonProvider {
  Future<Result<List<EpisodeSummary>, Failure>> seasonEpisodes(
    String showExternalId,
    int seasonNumber,
  );
}
