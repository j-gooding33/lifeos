import 'package:drift/drift.dart';

/// M8 Part 30. One row per user. `anchorDate`/`anchorWeekLabel` is the
/// single source of truth the two-week cycle counts from — see
/// `school_week_engine.dart`. If a holiday breaks the A/B alternation in a
/// way the raw calendar-week math doesn't predict (schools often just
/// announce which week you return to), the user re-anchors here rather
/// than the engine trying to guess school-specific holiday conventions.
class SchoolProfile extends Table {
  TextColumn get userId => text()();
  TextColumn get schoolName => text().nullable()();

  /// Wall time `HH:mm` (§9.1).
  TextColumn get dayStartTime => text().nullable()();
  TextColumn get dayEndTime => text().nullable()();

  /// `twoWeek` | `oneWeek`.
  TextColumn get timetableType =>
      text().withDefault(const Constant('twoWeek'))();

  /// `A` | `B` (meaningless for `oneWeek`).
  TextColumn get anchorWeekLabel => text().withDefault(const Constant('A'))();

  /// Civil date `YYYY-MM-DD` known to be [anchorWeekLabel].
  TextColumn get anchorDate => text().nullable()();
  IntColumn get createdAt => integer().nullable()();
  IntColumn get updatedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
