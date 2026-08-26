import 'package:drift/drift.dart';

/// §23.3, §16. Cached provider responses (TMDB, Open Library) — only
/// saved items are cached, per §36 risk 13.
class MediaMetadataCache extends Table {
  TextColumn get providerId => text()();
  TextColumn get externalId => text()();
  TextColumn get mediaType => text()();
  TextColumn get payload => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {providerId, externalId, mediaType};
}
