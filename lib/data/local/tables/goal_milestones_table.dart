import 'package:drift/drift.dart';

/// §23.3, §12.
class GoalMilestones extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text()();
  TextColumn get title => text().nullable()();
  RealColumn get targetValue => real().nullable()();
  TextColumn get dueDate => text().nullable()();
  IntColumn get completedAt => integer().nullable()();
  RealColumn get sortIndex => real().nullable()();
  IntColumn get updatedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
