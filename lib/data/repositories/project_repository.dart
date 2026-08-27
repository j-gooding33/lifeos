import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:uuid/uuid.dart';

/// §11. `colour`/`icon`/`deadline`/`goalId` have existed on the `Projects`
/// table since M4 — this wires them up now that a real Projects screen
/// exists, same pattern as School/Collections/Habits' pre-existing
/// unused columns this session.
class ProjectRepository {
  ProjectRepository(this._dao);

  final ProjectDao _dao;

  Stream<List<AppProject>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Stream<AppProject?> watchById(String id) => _dao.watchById(id).map((row) => row == null ? null : _toDomain(row));

  Future<Result<AppProject, Failure>> createProject({
    required String userId,
    required String title,
    String? description,
    String? colour,
    String? icon,
    CivilDate? deadline,
    String? goalId,
  }) async {
    try {
      final now = DateTime.now();
      final project = AppProject(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        description: description,
        colour: colour,
        icon: icon,
        deadline: deadline,
        goalId: goalId,
      );
      await _save(project, createdAt: now);
      return Ok(project);
    } on Object catch (e) {
      return Err(DatabaseFailure('createProject failed: $e'));
    }
  }

  Future<Result<void, Failure>> updateProject(AppProject project) async {
    try {
      await _save(project);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('updateProject failed: $e'));
    }
  }

  Future<Result<void, Failure>> setStatus(String id, ProjectStatus status) async {
    try {
      await _dao.updateStatus(
        id,
        status.name,
        completedAt: status == ProjectStatus.done ? DateTime.now().millisecondsSinceEpoch : null,
        clearCompletedAt: status != ProjectStatus.done,
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('setStatus failed: $e'));
    }
  }

  /// §11.4: "Delete 12 tasks too, or move them to no project?" — the
  /// caller (a confirmation dialog) decides which by calling
  /// `TaskRepository.deleteAllForProject`/`clearProjectForAll` itself
  /// before this; this never silently orphans or silently destroys either
  /// way.
  Future<Result<void, Failure>> deleteProject(String id) async {
    try {
      await _dao.softDelete(id, DateTime.now().millisecondsSinceEpoch);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('deleteProject failed: $e'));
    }
  }

  Future<void> _save(AppProject project, {DateTime? createdAt}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.ProjectsCompanion(
        id: Value(project.id),
        userId: Value(project.userId),
        title: Value(project.title),
        description: Value(project.description),
        colour: Value(project.colour),
        icon: Value(project.icon),
        deadline: Value(project.deadline?.toIso()),
        goalId: Value(project.goalId),
        status: Value(project.status.name),
        completedAt: Value(project.completedAt?.millisecondsSinceEpoch),
        createdAt: Value(createdAt?.millisecondsSinceEpoch ?? project.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppProject> _toDomainList(List<db.Project> rows) => rows.map(_toDomain).toList();

  AppProject _toDomain(db.Project row) {
    return AppProject(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      colour: row.colour,
      icon: row.icon,
      deadline: row.deadline == null ? null : CivilDate.parse(row.deadline!),
      goalId: row.goalId,
      status: ProjectStatus.values.firstWhere((s) => s.name == row.status, orElse: () => ProjectStatus.active),
      completedAt: row.completedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }
}
