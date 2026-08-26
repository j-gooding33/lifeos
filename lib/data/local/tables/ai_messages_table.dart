import 'package:drift/drift.dart';

/// §23.3, §19. `proposedActions`/`executedActions` are JSON — the AI layer
/// never writes directly; only what the user confirmed lands in
/// `executedActions` (CLAUDE.md rule 8).
class AiMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get role => text()();
  TextColumn get content => text().nullable()();
  TextColumn get proposedActions => text().nullable()();
  TextColumn get executedActions => text().nullable()();
  IntColumn get tokenCount => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
