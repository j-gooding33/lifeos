import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:uuid/uuid.dart';

class ProjectRepository {
  ProjectRepository(this._dao);

  final ProjectDao _dao;

  Stream<List<AppProject>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Future<Result<AppProject, Failure>> createProject({
    required String userId,
    required String title,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final project = AppProject(id: const Uuid().v4(), userId: userId, title: title, description: description);
      await _dao.upsert(
        db.ProjectsCompanion.insert(
          id: project.id,
          userId: userId,
          title: title,
          description: Value(description),
          createdAt: Value(now.millisecondsSinceEpoch),
          updatedAt: Value(now.millisecondsSinceEpoch),
        ),
      );
      return Ok(project);
    } on Object catch (e) {
      return Err(DatabaseFailure('createProject failed: $e'));
    }
  }

  List<AppProject> _toDomainList(List<db.Project> rows) => rows.map(_toDomain).toList();

  AppProject _toDomain(db.Project row) {
    return AppProject(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      status: row.status,
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
    );
  }
}
