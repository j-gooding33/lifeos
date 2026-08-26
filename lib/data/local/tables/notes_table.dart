import 'package:drift/drift.dart';

/// §23.3, §17. `blocks` is the block-editor JSON; `plainText` is a
/// denormalised copy the FTS index is built from.
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get blocks => text()();
  TextColumn get plainText => text().nullable()();
  TextColumn get folderId => text().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get colour => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
