import 'package:drift/drift.dart';

/// §23.3, §14. `startAt`/`endAt` are instants (epoch ms); `startDate`/
/// `endDate` are civil dates, kept alongside for all-day events.
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get endAt => integer().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  TextColumn get timezone => text().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get recurrenceRule => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get externalId => text().nullable()();
  TextColumn get externalCalendarId => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
