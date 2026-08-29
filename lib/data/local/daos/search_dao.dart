import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/search_index_sql.dart';

class SearchIndexRow {
  const SearchIndexRow({required this.entityType, required this.entityId, required this.title, required this.body});

  final String entityType;
  final String entityId;
  final String title;
  final String body;
}

/// §18.2. `search_index` is FTS5, not a Drift `Table` (see
/// `v1_indexes.dart`), so this queries it with raw SQL directly against
/// [AppDatabase] rather than through a generated `DriftAccessor` mixin,
/// which has nothing to generate when there's no typed table to bind to.
class SearchDao {
  SearchDao(this._db);

  final AppDatabase _db;

  /// Title matches are boosted over body matches via `bm25`'s per-column
  /// weights (title weight 10, body weight 1, tags weight 2) — an
  /// approximation of §18.1's "exact title match > prefix > token match >
  /// body match" without needing four separate query tiers.
  Future<List<SearchIndexRow>> search(String ftsQuery, {int limit = 200}) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT entity_type, entity_id, title, body
          FROM search_index
          WHERE search_index MATCH ?1
          ORDER BY bm25(search_index, 10.0, 1.0, 2.0)
          LIMIT ?2;
          ''',
          variables: [Variable.withString(ftsQuery), Variable.withInt(limit)],
        )
        .get();
    return [
      for (final row in rows)
        SearchIndexRow(
          entityType: row.read<String>('entity_type'),
          entityId: row.read<String>('entity_id'),
          title: row.read<String>('title'),
          body: row.read<String>('body'),
        ),
    ];
  }

  /// §18.2's "Rebuild command available in Settings → Data for corruption
  /// recovery" — clears and re-populates the whole index from source
  /// tables. Uses the same statements the v3/v4 migrations' one-time
  /// backfills do, so none of the three can drift apart.
  Future<void> rebuild() async {
    await _db.customStatement('DELETE FROM search_index;');
    for (final sql in searchIndexBackfillStatements) {
      await _db.customStatement(sql);
    }
    await _db.customStatement(documentSearchIndexBackfillStatement);
  }
}
