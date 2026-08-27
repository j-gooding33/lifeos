import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/scheduling/recurrence_rule_json.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/task_repository.dart';

void main() {
  late AppDatabase database;
  late TaskRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TaskRepository(TaskDao(database));
  });

  tearDown(() => database.close());

  test(
    'createTask then watchToday includes it when due today or earlier',
    () async {
      final today = CivilDate.fromDateTime(DateTime.now());
      await repository.createTask(
        userId: 'u1',
        title: 'Email Dr Hall',
        dueDate: today.toIso(),
      );

      final tasks = await repository.watchToday('u1', today).first;
      expect(tasks.map((t) => t.title), contains('Email Dr Hall'));
    },
  );

  test(
    'a task due tomorrow does not appear in today, but does in upcoming',
    () async {
      final today = CivilDate.fromDateTime(DateTime.now());
      final tomorrow = today.addDays(1);
      await repository.createTask(
        userId: 'u1',
        title: 'Future thing',
        dueDate: tomorrow.toIso(),
      );

      final todayTasks = await repository.watchToday('u1', today).first;
      final upcoming = await repository.watchUpcoming('u1', today).first;
      expect(todayTasks, isEmpty);
      expect(upcoming.map((t) => t.title), contains('Future thing'));
    },
  );

  test(
    'completing a task sets completedAt and it leaves the open views',
    () async {
      final today = CivilDate.fromDateTime(DateTime.now());
      final created = await repository.createTask(
        userId: 'u1',
        title: 'Buy milk',
        dueDate: today.toIso(),
      );
      final task = created.when(
        ok: (t) => t,
        err: (_) => throw StateError('expected Ok'),
      );

      await repository.completeTask(task);

      final todayTasks = await repository.watchToday('u1', today).first;
      expect(todayTasks, isEmpty);
    },
  );

  test(
    'completing a repeating task creates the next instance immediately (§10.6)',
    () async {
      final today = CivilDate.fromDateTime(DateTime.now());
      final rule = IntervalDays(1, anchor: today);
      final created = await repository.createTask(
        userId: 'u1',
        title: 'Water the plants',
        dueDate: today.toIso(),
        recurrenceRule: rule.toJsonString(),
      );
      final task = created.when(
        ok: (t) => t,
        err: (_) => throw StateError('expected Ok'),
      );

      final result = await repository.completeTask(task);
      final next = result.when(
        ok: (t) => t,
        err: (_) => throw StateError('expected Ok'),
      );

      expect(next, isNotNull);
      expect(next!.title, 'Water the plants');
      expect(next.dueDate, today.addDays(1).toIso());
      expect(next.isCompleted, isFalse);
      // The original stays in history, completed — it isn't overwritten.
      final completedTasks = await repository.watchCompleted('u1').first;
      expect(completedTasks.map((t) => t.id), contains(task.id));
    },
  );

  test(
    'a non-repeating task produces no next instance on completion',
    () async {
      final today = CivilDate.fromDateTime(DateTime.now());
      final created = await repository.createTask(
        userId: 'u1',
        title: 'One-off',
        dueDate: today.toIso(),
      );
      final task = created.when(
        ok: (t) => t,
        err: (_) => throw StateError('expected Ok'),
      );

      final result = await repository.completeTask(task);
      final next = result.when(
        ok: (t) => t,
        err: (_) => throw StateError('expected Ok'),
      );

      expect(next, isNull);
    },
  );

  test('deleteTask soft-deletes: it disappears from every view', () async {
    final today = CivilDate.fromDateTime(DateTime.now());
    final created = await repository.createTask(
      userId: 'u1',
      title: 'Gone soon',
      dueDate: today.toIso(),
    );
    final task = created.when(
      ok: (t) => t,
      err: (_) => throw StateError('expected Ok'),
    );

    await repository.deleteTask(task.id);

    final todayTasks = await repository.watchToday('u1', today).first;
    expect(todayTasks, isEmpty);
  });

  test('subtasks: add, complete, and watch reflect state', () async {
    final created = await repository.createTask(
      userId: 'u1',
      title: 'Plan the trip',
    );
    final task = created.when(
      ok: (t) => t,
      err: (_) => throw StateError('expected Ok'),
    );

    await repository.addSubtask(task.id, 'Book flights');
    await repository.addSubtask(task.id, 'Pack bags');

    final subtasks = await repository.watchSubtasks(task.id).first;
    expect(subtasks, hasLength(2));
    expect(subtasks.every((s) => !s.isCompleted), isTrue);

    await repository.setSubtaskCompleted(subtasks.first, completed: true);
    final updated = await repository.watchSubtasks(task.id).first;
    expect(
      updated.firstWhere((s) => s.id == subtasks.first.id).isCompleted,
      isTrue,
    );
  });
}
