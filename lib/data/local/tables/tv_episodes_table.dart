import 'package:drift/drift.dart';

/// §23.3 extension, M8 Part 12-13. One row per episode of a `library_items`
/// row whose `mediaType == 'tv'`. Combines cached provider metadata (title,
/// air date, still image) with the user's own watch/rating/log state, the
/// same shape `library_items` already uses for the show itself.
///
/// Per-episode tracking was postponed at M1 (`POSTPONED.md`) as unneeded
/// for v1; explicitly un-postponed for M8 at the project owner's request —
/// see `DECISIONS.md`.
class TvEpisodes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get libraryItemId => text()();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get overview => text().nullable()();

  /// Civil date `YYYY-MM-DD` (§9.1), as returned by the provider.
  TextColumn get airDate => text().nullable()();
  TextColumn get stillPath => text().nullable()();
  IntColumn get watchedAt => integer().nullable()();

  /// 0–6 in 0.5 steps. 6 is a distinct "personal favourite" tier, not "6
  /// out of 5" — see `DECISIONS.md`.
  RealColumn get rating => real().nullable()();
  TextColumn get log => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
