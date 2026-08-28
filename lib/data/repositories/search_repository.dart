import 'package:life_os/data/local/daos/search_dao.dart';

class SearchResult {
  const SearchResult({required this.entityType, required this.entityId, required this.title, required this.snippet});

  final String entityType;
  final String entityId;
  final String title;
  final String snippet;
}

class SearchResultGroup {
  const SearchResultGroup({required this.entityType, required this.results});

  final String entityType;
  final List<SearchResult> results;
}

/// §18. FTS5 MATCH -> rank -> group (§18.2's own pipeline description; the
/// "cap at 8 per group with Show all" part is the screen's job, not this
/// repository's — it needs the full group to reveal the rest). No
/// `user_id` filter: `search_index` has no such column (see
/// `v1_indexes.dart`) — fine here, since this is a local-first, one-user-
/// per-device database, not a shared/multi-tenant one.
class SearchRepository {
  SearchRepository(this._dao);

  final SearchDao _dao;

  Future<List<SearchResultGroup>> search(String query) async {
    final ftsQuery = _buildFtsQuery(query);
    if (ftsQuery.isEmpty) return const [];

    final rows = await _dao.search(ftsQuery);
    final byType = <String, List<SearchResult>>{};
    for (final row in rows) {
      (byType[row.entityType] ??= []).add(
        SearchResult(entityType: row.entityType, entityId: row.entityId, title: row.title, snippet: _snippet(row.body)),
      );
    }

    return [for (final entry in byType.entries) SearchResultGroup(entityType: entry.key, results: entry.value)];
  }

  Future<void> rebuild() => _dao.rebuild();

  String _snippet(String body) => body.length <= 120 ? body : '${body.substring(0, 120)}…';

  /// FTS5's query syntax treats punctuation and bare `"`/`*`/`:`/`-` as
  /// operators — strip everything but word characters per token, then
  /// suffix each with `*` for prefix matching (§18.1: "exact title match >
  /// prefix > token match").
  String _buildFtsQuery(String raw) {
    final tokens = raw
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'[^\w]'), ''))
        .where((t) => t.isNotEmpty)
        .map((t) => '$t*');
    return tokens.join(' ');
  }
}
