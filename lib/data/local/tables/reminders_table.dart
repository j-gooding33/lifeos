import 'package:drift/drift.dart';

/// §23.3, §22.3. `platformId` is the OS-level notification id the
/// `NotificationScheduler` uses to cancel/reschedule.
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get fireAt => integer()();
  IntColumn get offsetMinutes => integer().nullable()();
  IntColumn get platformId => integer().nullable()();
  IntColumn get deliveredAt => integer().nullable()();
  IntColumn get cancelledAt => integer().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
