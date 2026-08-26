import 'package:drift/drift.dart';

/// §23.3, §7.2. A named intention with a rhythm. Habits are plans with
/// `kind = 'habit'` (§7.1) — there is no separate habits engine.
class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get kind => text().withDefault(const Constant('plan'))();
  TextColumn get title => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get mediaType => text().nullable()();
  TextColumn get rule => text()();
  IntColumn get generationVersion => integer().withDefault(const Constant(1))();
  TextColumn get anchorDate => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  IntColumn get endAfterCount => integer().nullable()();
  TextColumn get timeOfDay => text().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get target => text().nullable()();
  TextColumn get reminderOffsets => text().nullable()();
  TextColumn get missedPolicy => text().withDefault(const Constant('markMissed'))();
  TextColumn get scheduleMode => text().withDefault(const Constant('fixed'))();
  IntColumn get graceDays => integer().withDefault(const Constant(0))();
  TextColumn get pauseFrom => text().nullable()();
  TextColumn get pauseUntil => text().nullable()();
  TextColumn get goalId => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get sortIndex => real().nullable()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
