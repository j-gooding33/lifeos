import 'package:drift/drift.dart';

/// §23.3, §22.2. `amountMinor` is integer minor units (pence) — money is
/// never a `double` (CLAUDE.md conventions).
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get date => text()();
  TextColumn get note => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get attachmentId => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
