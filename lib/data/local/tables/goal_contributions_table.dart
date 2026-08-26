import 'package:drift/drift.dart';

/// §23.3, §12.4. `idx_contrib_dedupe` (goalId+sourceType+sourceId unique)
/// lives in `data/local/migrations/` — it's what makes completing and
/// un-completing an occurrence increment/decrement a goal exactly once.
class GoalContributions extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  RealColumn get value => real()();
  TextColumn get date => text()();
  IntColumn get createdAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
