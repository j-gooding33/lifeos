import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/media/media_types.dart' show MediaType;

/// §16.3. One vocabulary shared by films, TV and books — "want to watch /
/// watching / watched" and "want to read / reading / read" are the same
/// four states underneath, so the query layer (sort, filter, stats) is
/// shared across all three media types instead of tripled.
enum LibraryItemStatus { wishlist, inProgress, done, abandoned }

/// A film, TV show, or book the user has saved. Backed by `library_items`
/// (§23.3) — one polymorphic table, not per-type tables (see DECISIONS.md).
class AppLibraryItem {
  AppLibraryItem({
    required this.id,
    required this.userId,
    required this.mediaType,
    required this.title,
    this.sortTitle,
    this.providerId,
    this.externalId,
    this.year,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.runtimeMinutes,
    this.genres = const [],
    this.creators = const [],
    this.status = LibraryItemStatus.wishlist,
    this.rating,
    this.isFavourite = false,
    this.notes,
    this.progressValue,
    this.progressUnit,
    DateTime? addedAt,
    this.startedAt,
    this.finishedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  final String id;
  final String userId;
  final MediaType mediaType;
  final String title;
  final String? sortTitle;
  final String? providerId;
  final String? externalId;
  final int? year;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final int? runtimeMinutes;
  final List<String> genres;

  /// Director(s) for film, creator(s) for TV, author for books.
  final List<String> creators;
  final LibraryItemStatus status;

  /// 0–5 in 0.5 steps. Films, TV shows (the overall show rating — see
  /// `AppTvEpisode` for per-episode 0–6 ratings) and books. Independent of
  /// any Top-N list (Part 42) — nothing here is derived from that or
  /// vice versa.
  final double? rating;
  final bool isFavourite;

  /// The personal log/review (Parts 5, 22).
  final String? notes;
  final double? progressValue;
  final String? progressUnit;
  final DateTime addedAt;
  final DateTime? startedAt;

  /// Watch date (films/TV) or finish date (books).
  final DateTime? finishedAt;

  bool get isRated => rating != null;

  String get author => creators.isEmpty ? '' : creators.join(', ');

  AppLibraryItem copyWith({
    String? title,
    LibraryItemStatus? status,
    double? rating,
    bool clearRating = false,
    bool? isFavourite,
    String? notes,
    bool clearNotes = false,
    double? progressValue,
    String? progressUnit,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
  }) {
    return AppLibraryItem(
      id: id,
      userId: userId,
      mediaType: mediaType,
      title: title ?? this.title,
      sortTitle: sortTitle,
      providerId: providerId,
      externalId: externalId,
      year: year,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      runtimeMinutes: runtimeMinutes,
      genres: genres,
      creators: creators,
      status: status ?? this.status,
      rating: clearRating ? null : (rating ?? this.rating),
      isFavourite: isFavourite ?? this.isFavourite,
      notes: clearNotes ? null : (notes ?? this.notes),
      progressValue: progressValue ?? this.progressValue,
      progressUnit: progressUnit ?? this.progressUnit,
      addedAt: addedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
    );
  }
}

/// §12-13/M8. One episode of a `library_items` row whose `mediaType` is
/// `tv`. See `tv_episodes_table.dart` for why this combines cached
/// metadata with the user's own state, same as `library_items` itself.
class AppTvEpisode {
  const AppTvEpisode({
    required this.id,
    required this.libraryItemId,
    required this.seasonNumber,
    required this.episodeNumber,
    this.title,
    this.overview,
    this.airDate,
    this.stillPath,
    this.watchedAt,
    this.rating,
    this.log,
  });

  final String id;
  final String libraryItemId;
  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final String? overview;
  final CivilDate? airDate;
  final String? stillPath;
  final DateTime? watchedAt;

  /// 0–6 in 0.5 steps. 6 is a distinct "personal favourite" tier — see
  /// DECISIONS.md — never averaged as "out of 5".
  final double? rating;
  final String? log;

  bool get isWatched => watchedAt != null;
  bool get isPersonalFavourite => rating != null && rating! >= 6;
}
