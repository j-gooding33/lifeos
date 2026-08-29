import 'package:drift/drift.dart';

/// §17.3, §11.3. A document linked to another entity — a project's
/// "Files" section is the first consumer, same polymorphic-link shape
/// `note_links_table.dart` already uses for notes.
class DocumentLinks extends Table {
  TextColumn get documentId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get createdAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {documentId, entityType, entityId};
}
