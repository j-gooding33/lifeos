import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/project_repository.dart';

AppProject _okProject(Result<AppProject, Failure> result) =>
    result.when(ok: (p) => p, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late ProjectRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProjectRepository(ProjectDao(database));
  });

  tearDown(() => database.close());

  test('create then watchAll/watchById round-trips every field (§11.2)', () async {
    final created = await repository.createProject(
      userId: 'u1',
      title: 'Redesign the kitchen',
      description: 'Plan, budget, execute',
      colour: 'goals',
      icon: 'kitchen_outlined',
      deadline: const CivilDate(2026, 12, 1),
    );
    final project = _okProject(created);
    expect(project.status, ProjectStatus.active);

    final all = await repository.watchAll('u1').first;
    expect(all, hasLength(1));
    expect(all.single.title, 'Redesign the kitchen');
    expect(all.single.colour, 'goals');
    expect(all.single.deadline, const CivilDate(2026, 12, 1));

    final byId = await repository.watchById(project.id).first;
    expect(byId!.description, 'Plan, budget, execute');
  });

  test('setStatus to done stamps completedAt; moving off done clears it', () async {
    final created = await repository.createProject(userId: 'u1', title: 'Ship it');
    final project = _okProject(created);

    await repository.setStatus(project.id, ProjectStatus.done);
    var reloaded = await repository.watchById(project.id).first;
    expect(reloaded!.status, ProjectStatus.done);
    expect(reloaded.completedAt, isNotNull);

    await repository.setStatus(project.id, ProjectStatus.active);
    reloaded = await repository.watchById(project.id).first;
    expect(reloaded!.status, ProjectStatus.active);
    expect(reloaded.completedAt, isNull);
  });

  test('updateProject overwrites the stored row', () async {
    final created = await repository.createProject(userId: 'u1', title: 'Old title');
    final project = _okProject(created);

    await repository.updateProject(project.copyWith(title: 'New title', colour: 'plans'));
    final reloaded = await repository.watchById(project.id).first;
    expect(reloaded!.title, 'New title');
    expect(reloaded.colour, 'plans');
  });

  test('deleteProject is a soft delete: it disappears from watchAll and watchById', () async {
    final created = await repository.createProject(userId: 'u1', title: 'Temporary');
    final project = _okProject(created);

    await repository.deleteProject(project.id);
    expect(await repository.watchAll('u1').first, isEmpty);
    expect(await repository.watchById(project.id).first, isNull);
  });

  test("watchAll only returns the given user's projects", () async {
    await repository.createProject(userId: 'u1', title: 'Mine');
    await repository.createProject(userId: 'u2', title: 'Not mine');
    final all = await repository.watchAll('u1').first;
    expect(all.map((p) => p.title), ['Mine']);
  });
}
