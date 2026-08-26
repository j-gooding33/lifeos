import 'package:drift/drift.dart';

/// §23.3, §15. A collection can hold films, books and notes together.
class CollectionItems extends Table {
  TextColumn get collectionId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  RealColumn get sortIndex => real().nullable()();
  IntColumn get addedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {collectionId, entityType, entityId};
}
