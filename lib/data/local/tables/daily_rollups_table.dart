import 'package:drift/drift.dart';

/// §23.3, §20. One row per user per day — the aggregation Stats and Your
/// Year read from, rather than scanning every source table live.
class DailyRollups extends Table {
  TextColumn get userId => text()();
  TextColumn get date => text()();
  IntColumn get tasksCompleted => integer().withDefault(const Constant(0))();
  IntColumn get tasksCreated => integer().withDefault(const Constant(0))();
  IntColumn get occurrencesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get occurrencesMissed => integer().withDefault(const Constant(0))();
  IntColumn get occurrencesSkipped => integer().withDefault(const Constant(0))();
  IntColumn get habitsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get habitsDue => integer().withDefault(const Constant(0))();
  IntColumn get filmsWatched => integer().withDefault(const Constant(0))();
  IntColumn get booksFinished => integer().withDefault(const Constant(0))();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get studyMinutes => integer().withDefault(const Constant(0))();
  IntColumn get activityMinutes => integer().withDefault(const Constant(0))();
  IntColumn get goalContributions => integer().withDefault(const Constant(0))();
  IntColumn get expenseTotalMinor => integer().withDefault(const Constant(0))();
  IntColumn get journalWritten => integer().withDefault(const Constant(0))();
  IntColumn get activityScore => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId, date};
}
