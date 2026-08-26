import 'package:drift/drift.dart';

/// §23.3, §22.1. One entry per day (`idx_journal_date`, in migrations,
/// enforces that), editable any day.
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get date => text()();
  TextColumn get blocks => text().nullable()();
  TextColumn get plainText => text().nullable()();
  IntColumn get mood => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
