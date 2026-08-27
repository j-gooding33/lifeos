import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/projects_table.dart';

part 'project_dao.g.dart';

/// Minimal — the `Projects` table (§23.3, §11) has existed since the
/// original schema, but nothing wrote to it until onboarding (item 8)
/// needed somewhere real to put "what are you currently working on"
/// answers. No dedicated Projects screen exists yet (`Routes.projects` is
/// still the honest placeholder) — these rows are real and will show up
/// the moment that screen is built.
@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Stream<List<Project>> watchAll(String userId) {
    final query = select(projects)
      ..where((p) => p.userId.equals(userId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.asc(p.sortIndex)]);
    return query.watch();
  }

  Stream<Project?> watchById(String id) {
    final query = select(projects)..where((p) => p.id.equals(id) & p.deletedAt.isNull());
    return query.watchSingleOrNull();
  }

  Future<void> upsert(ProjectsCompanion entry) => into(projects).insertOnConflictUpdate(entry);

  Future<void> updateStatus(
    String id,
    String status, {
    int? completedAt,
    bool clearCompletedAt = false,
  }) {
    return (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(
        status: Value(status),
        completedAt: clearCompletedAt ? const Value(null) : (completedAt == null ? const Value.absent() : Value(completedAt)),
      ),
    );
  }

  Future<void> softDelete(String id, int now) => (update(projects)..where((p) => p.id.equals(id))).write(
    ProjectsCompanion(deletedAt: Value(now)),
  );
}
