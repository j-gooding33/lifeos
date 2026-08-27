import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/activity_log_table.dart';

part 'activity_log_dao.g.dart';

/// §8.4 point 6: every occurrence move (and, later, any AI-sourced change —
/// CLAUDE.md rule 8) writes a row here so the change is visible in history.
@DriftAccessor(tables: [ActivityLog])
class ActivityLogDao extends DatabaseAccessor<AppDatabase>
    with _$ActivityLogDaoMixin {
  ActivityLogDao(super.db);

  Future<void> log({
    required String id,
    required String userId,
    required String entityType,
    required String entityId,
    required String action,
    String? payload,
    String source = 'user',
  }) {
    return into(activityLog).insert(
      ActivityLogCompanion.insert(
        id: id,
        userId: userId,
        entityType: Value(entityType),
        entityId: Value(entityId),
        action: Value(action),
        payload: Value(payload),
        source: Value(source),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
