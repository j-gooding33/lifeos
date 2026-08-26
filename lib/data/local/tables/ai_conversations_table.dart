import 'package:drift/drift.dart';

/// §23.3, §19.
class AiConversations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
