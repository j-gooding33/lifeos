import 'package:drift/drift.dart';

/// M8 Part 7/16/24. A manually-curated, ranked, capped list per media type
/// — "My Top 5 Films", "My Top 5 TV Shows", "My Top 3 Books". Deliberately
/// its own table rather than reusing `collections`: a top list has exactly
/// one instance per `(userId, mediaType)`, a hard cap enforced by the
/// repository, and specific "1./2./3." ranking UI, none of which fit
/// `collections`' general "arbitrarily many, user-named, unbounded" shape.
/// Independent of `library_items.rating` by design (Part 42) — nothing
/// here is derived from star ratings.
class TopListItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// `film` | `tv` | `book`.
  TextColumn get mediaType => text()();
  TextColumn get libraryItemId => text()();

  /// 1-based.
  IntColumn get rank => integer()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
