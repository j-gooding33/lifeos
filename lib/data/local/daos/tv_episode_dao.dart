import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/tv_episodes_table.dart';

part 'tv_episode_dao.g.dart';

@DriftAccessor(tables: [TvEpisodes])
class TvEpisodeDao extends DatabaseAccessor<AppDatabase>
    with _$TvEpisodeDaoMixin {
  TvEpisodeDao(super.db);

  Stream<List<TvEpisode>> watchForShow(String libraryItemId) {
    final query = select(tvEpisodes)
      ..where(
        (e) => e.libraryItemId.equals(libraryItemId) & e.deletedAt.isNull(),
      )
      ..orderBy([
        (e) => OrderingTerm.asc(e.seasonNumber),
        (e) => OrderingTerm.asc(e.episodeNumber),
      ]);
    return query.watch();
  }

  Stream<List<TvEpisode>> watchForSeason(
    String libraryItemId,
    int seasonNumber,
  ) {
    final query = select(tvEpisodes)
      ..where(
        (e) =>
            e.libraryItemId.equals(libraryItemId) &
            e.seasonNumber.equals(seasonNumber) &
            e.deletedAt.isNull(),
      )
      ..orderBy([(e) => OrderingTerm.asc(e.episodeNumber)]);
    return query.watch();
  }

  Stream<List<TvEpisode>> watchRated(String userId) {
    final query = select(tvEpisodes)
      ..where(
        (e) =>
            e.userId.equals(userId) &
            e.deletedAt.isNull() &
            e.rating.isNotNull(),
      );
    return query.watch();
  }

  Future<TvEpisode?> getBySeasonEpisode(
    String libraryItemId,
    int seasonNumber,
    int episodeNumber,
  ) {
    return (select(tvEpisodes)..where(
          (e) =>
              e.libraryItemId.equals(libraryItemId) &
              e.seasonNumber.equals(seasonNumber) &
              e.episodeNumber.equals(episodeNumber) &
              e.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  Future<void> upsert(TvEpisodesCompanion entry) =>
      into(tvEpisodes).insertOnConflictUpdate(entry);

  Future<void> softDelete(String id, int now) =>
      (update(tvEpisodes)..where((e) => e.id.equals(id))).write(
        TvEpisodesCompanion(deletedAt: Value(now)),
      );

  /// A sparse partial update on an *existing* row — `update().write()`,
  /// not `insertOnConflictUpdate`, which needs every NOT NULL column
  /// supplied even when only one field is actually changing (see the
  /// same note on `PlanDao.updateOccurrenceStatus`).
  Future<void> updateUserState(
    String id, {
    required int updatedAt,
    int? watchedAt,
    bool clearWatchedAt = false,
    double? rating,
    bool clearRating = false,
    String? log,
    bool clearLog = false,
  }) {
    return (update(tvEpisodes)..where((e) => e.id.equals(id))).write(
      TvEpisodesCompanion(
        watchedAt: clearWatchedAt
            ? const Value(null)
            : (watchedAt == null ? const Value.absent() : Value(watchedAt)),
        rating: clearRating
            ? const Value(null)
            : (rating == null ? const Value.absent() : Value(rating)),
        log: clearLog
            ? const Value(null)
            : (log == null ? const Value.absent() : Value(log)),
        updatedAt: Value(updatedAt),
      ),
    );
  }
}
