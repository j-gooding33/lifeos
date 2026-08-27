import 'package:drift/drift.dart';

/// M8 Part 33. A gap *within* a term (half-term, an inset/training day) or
/// a holiday between terms — either way, no lessons render on a date
/// covered by a closure, regardless of what `school_lessons` would
/// otherwise say for that weekday.
class SchoolClosures extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();

  /// `holiday` | `halfTerm` | `inset` | `custom`.
  TextColumn get type => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
