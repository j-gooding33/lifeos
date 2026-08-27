/// §16.2, M8. Provider-agnostic models — feature code depends on these,
/// never on a provider's raw response shape, so swapping `TmdbMetadataProvider`
/// for something else later is a one-file change (rule: "make API
/// integrations replaceable").
enum MediaType { film, tv, book }

enum ImageSize { thumbnail, small, medium, large, original }

class MediaSearchResult {
  const MediaSearchResult({
    required this.externalId,
    required this.title,
    this.year,
    this.posterPath,
    this.overview,
    this.genres = const [],
    this.runtimeMinutes,
    this.author,
  });

  final String externalId;
  final String title;
  final int? year;
  final String? posterPath;
  final String? overview;
  final List<String> genres;

  /// Film only — TMDB's search endpoint doesn't return runtime; only
  /// populated when a provider's detail call already ran (e.g. manual add
  /// confirmation), otherwise null (§16.7: no poster/data is "missing", not
  /// a crash).
  final int? runtimeMinutes;

  /// Books only.
  final String? author;
}

class MediaDetail {
  const MediaDetail({
    required this.externalId,
    required this.mediaType,
    required this.title,
    this.year,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.runtimeMinutes,
    this.genres = const [],
    this.creators = const [],
    this.author,
    this.seasonCount,
  });

  final String externalId;
  final MediaType mediaType;
  final String title;
  final int? year;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final int? runtimeMinutes;
  final List<String> genres;

  /// Director(s) for film, creator(s) for TV.
  final List<String> creators;
  final String? author;

  /// TV only — how many seasons TMDB reports, so the UI can offer season
  /// selection without a second round trip just to find the count.
  final int? seasonCount;
}

/// One episode as a provider reports it — TMDB's `/tv/{id}/season/{n}`
/// endpoint, so per-episode metadata comes from the same provider as the
/// show itself, no second API needed.
class EpisodeSummary {
  const EpisodeSummary({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.airDate,
    this.stillPath,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;

  /// Civil date `YYYY-MM-DD`, or null if the provider doesn't know yet
  /// (unaired episodes).
  final String? airDate;
  final String? stillPath;
}
