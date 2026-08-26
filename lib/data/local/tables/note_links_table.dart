import 'package:drift/drift.dart';

/// §23.3, §17. A note linked from a task also appears on the task screen,
/// and vice versa — this table is that link, in either direction.
class NoteLinks extends Table {
  TextColumn get noteId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {noteId, entityType, entityId};
}
