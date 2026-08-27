import 'package:drift/drift.dart';

/// M8 Part 33. School is only "in session" on dates covered by a term —
/// dates outside every term (summer holiday, or before the first term is
/// entered) are non-school days by default, with no need for a matching
/// closure row.
class SchoolTerms extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
