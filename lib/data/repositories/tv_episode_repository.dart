import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/tv_episode_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:uuid/uuid.dart';

/// M8 Parts 12-14. Per-episode tracking, un-postponed from M1's
/// `POSTPONED.md` entry at the project owner's explicit request — see
/// `DECISIONS.md`.
class TvEpisodeRepository {
  TvEpisodeRepository(this._dao);

  final TvEpisodeDao _dao;

  Stream<List<AppTvEpisode>> watchForShow(String libraryItemId) {
    return _dao.watchForShow(libraryItemId).map(_toDomainList);
  }

  Stream<List<AppTvEpisode>> watchForSeason(
    String libraryItemId,
    int seasonNumber,
  ) {
    return _dao.watchForSeason(libraryItemId, seasonNumber).map(_toDomainList);
  }

  Stream<List<AppTvEpisode>> watchRated(String userId) {
    return _dao.watchRated(userId).map(_toDomainList);
  }

  /// Imports a season's episode list from the metadata provider, creating
  /// rows that don't exist yet — never overwriting a user's existing
  /// watched/rating/log state for an episode already tracked (matched by
  /// the natural `(libraryItemId, seasonNumber, episodeNumber)` key).
  Future<Result<void, Failure>> importSeason({
    required String userId,
    required String libraryItemId,
    required List<EpisodeSummary> episodes,
  }) async {
    try {
      for (final episode in episodes) {
        final existing = await _dao.getBySeasonEpisode(
          libraryItemId,
          episode.seasonNumber,
          episode.episodeNumber,
        );
        final now = DateTime.now().millisecondsSinceEpoch;
        await _dao.upsert(
          db.TvEpisodesCompanion(
            id: Value(existing?.id ?? const Uuid().v4()),
            userId: Value(userId),
            libraryItemId: Value(libraryItemId),
            seasonNumber: Value(episode.seasonNumber),
            episodeNumber: Value(episode.episodeNumber),
            title: Value(episode.title),
            overview: Value(episode.overview),
            airDate: Value(episode.airDate),
            stillPath: Value(episode.stillPath),
            watchedAt: existing == null
                ? const Value.absent()
                : Value(existing.watchedAt),
            rating: existing == null
                ? const Value.absent()
                : Value(existing.rating),
            log: existing == null ? const Value.absent() : Value(existing.log),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('importSeason failed: $e'));
    }
  }

  Future<Result<void, Failure>> markWatched(
    String episodeId, {
    required DateTime watchedDate,
  }) async {
    try {
      await _dao.updateUserState(
        episodeId,
        watchedAt: watchedDate.millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('markWatched failed: $e'));
    }
  }

  Future<Result<void, Failure>> markUnwatched(String episodeId) async {
    try {
      await _dao.updateUserState(
        episodeId,
        clearWatchedAt: true,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('markUnwatched failed: $e'));
    }
  }

  /// 0–6 in 0.5 steps (Part 12) — the caller (UI) is what constrains the
  /// range; this just stores whatever it's given, same trust boundary as
  /// every other repository in this codebase.
  Future<Result<void, Failure>> setRating(
    String episodeId,
    double? rating,
  ) async {
    try {
      await _dao.updateUserState(
        episodeId,
        rating: rating,
        clearRating: rating == null,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setRating failed: $e'));
    }
  }

  Future<Result<void, Failure>> setLog(String episodeId, String? log) async {
    try {
      await _dao.updateUserState(
        episodeId,
        log: log,
        clearLog: log == null,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setLog failed: $e'));
    }
  }

  List<AppTvEpisode> _toDomainList(List<db.TvEpisode> rows) =>
      rows.map(_toDomain).toList();

  AppTvEpisode _toDomain(db.TvEpisode row) {
    return AppTvEpisode(
      id: row.id,
      libraryItemId: row.libraryItemId,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      overview: row.overview,
      airDate: row.airDate == null ? null : CivilDate.parse(row.airDate!),
      stillPath: row.stillPath,
      watchedAt: row.watchedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.watchedAt!),
      rating: row.rating,
      log: row.log,
    );
  }
}
