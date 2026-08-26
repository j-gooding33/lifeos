import 'package:drift/drift.dart';

/// §23.3, §16. Films, TV, books, links and documents all share this table,
/// distinguished by `mediaType`.
class LibraryItems extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get mediaType => text()();
  TextColumn get title => text()();
  TextColumn get sortTitle => text().nullable()();
  TextColumn get providerId => text().nullable()();
  TextColumn get externalId => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  TextColumn get overview => text().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get genres => text().nullable()();
  TextColumn get creators => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('wishlist'))();
  RealColumn get rating => real().nullable()();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  RealColumn get progressValue => real().nullable()();
  TextColumn get progressUnit => text().nullable()();
  IntColumn get addedAt => integer().nullable()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get finishedAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
