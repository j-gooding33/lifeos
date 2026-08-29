import 'package:drift/drift.dart';

/// §17.3. A locally-stored file. `storedName` is a UUID-based filename
/// inside the app's own `documents/` directory (never the OS path the
/// user picked from — that path can vanish or move); `originalName` is
/// what the user sees. "Uploaded to the user's storage bucket on sync" is
/// not built — no sync backend exists yet, same blocker as everywhere
/// else this session that needs one; see DECISIONS.md.
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get storedName => text()();
  TextColumn get originalName => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
