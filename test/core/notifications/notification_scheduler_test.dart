import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/notifications/notification_scheduler.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/event_repository.dart';
import 'package:life_os/data/repositories/models/app_project.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';

T _ok<T>(Result<T, Failure> result) => result.when(ok: (v) => v, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late NotificationScheduler scheduler;
  late TaskRepository taskRepository;
  late PlanRepository planRepository;
  late EventRepository eventRepository;
  late ProjectRepository projectRepository;
  late PreferencesRepository preferencesRepository;
  final today = CivilDate.fromDateTime(DateTime.now());

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    scheduler = NotificationScheduler(database);
    taskRepository = TaskRepository(TaskDao(database));
    planRepository = PlanRepository(PlanDao(database), ActivityLogDao(database));
    eventRepository = EventRepository(EventDao(database));
    projectRepository = ProjectRepository(ProjectDao(database));
    preferencesRepository = PreferencesRepository(PreferencesDao(database));
  });

  tearDown(() => database.close());

  Future<void> enableMaster() => preferencesRepository.set('u1', 'notif.master', 'true');
  Future<void> enable(String key) => preferencesRepository.set('u1', key, 'true');

  test('the master switch being off suppresses everything, even with categories on', () async {
    await enable('notif.taskReminders');
    await taskRepository.createTask(userId: 'u1', title: 'Water plants', dueDate: today.addDays(1).toIso());

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, isEmpty);
  });

  test('a task with a future due date and time is scheduled once its category is on', () async {
    await enableMaster();
    await enable('notif.taskReminders');
    final created = _ok(
      await taskRepository.createTask(userId: 'u1', title: 'Water plants', dueDate: today.addDays(1).toIso()),
    );
    await taskRepository.updateTask(created.copyWith(dueTime: '08:30'));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, hasLength(1));
    expect(schedule.single.body, 'Water plants');
    expect(schedule.single.payload, 'task:${created.id}');
    expect(schedule.single.scheduledAt.hour, 8);
    expect(schedule.single.scheduledAt.minute, 30);
  });

  test('a task due date with no time falls back to 9am, not silently dropped', () async {
    await enableMaster();
    await enable('notif.taskReminders');
    await taskRepository.createTask(userId: 'u1', title: 'No time set', dueDate: today.addDays(1).toIso());

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule.single.scheduledAt.hour, 9);
  });

  test('a completed task is never scheduled', () async {
    await enableMaster();
    await enable('notif.taskReminders');
    final created = _ok(
      await taskRepository.createTask(userId: 'u1', title: 'Already done', dueDate: today.addDays(1).toIso()),
    );
    await taskRepository.completeTask(created);

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, isEmpty);
  });

  test("a category left off doesn't suppress a different category", () async {
    await enableMaster();
    await enable('notif.eventAlerts');
    // notif.taskReminders deliberately left off.
    await taskRepository.createTask(userId: 'u1', title: 'Ignored task', dueDate: today.addDays(1).toIso());
    await eventRepository.createEvent(userId: 'u1', title: 'Dentist', startAt: DateTime.now().add(const Duration(days: 1)));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, hasLength(1));
    expect(schedule.single.body, 'Dentist');
  });

  test('a candidate landing inside quiet hours is suppressed', () async {
    await enableMaster();
    await enable('notif.taskReminders');
    await preferencesRepository.set('u1', 'notif.quietStart', '22:00');
    await preferencesRepository.set('u1', 'notif.quietEnd', '07:00');
    final created = _ok(
      await taskRepository.createTask(userId: 'u1', title: 'Late night reminder', dueDate: today.addDays(1).toIso()),
    );
    await taskRepository.updateTask(created.copyWith(dueTime: '23:00'));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, isEmpty);
  });

  test("a plan occurrence uses the plan's own timeOfDay when the occurrence has none set", () async {
    await enableMaster();
    await enable('notif.planOccurrences');
    final plan = _ok(
      await planRepository.createPlan(
        userId: 'u1',
        title: 'Morning run',
        rule: IntervalDays(1, anchor: today),
        timeOfDay: '06:30',
      ),
    );

    final schedule = await scheduler.buildSchedule('u1');
    final planCandidate = schedule.where((c) => c.payload == 'plan:${plan.id}').toList();
    expect(planCandidate, isNotEmpty);
    expect(planCandidate.first.scheduledAt.hour, 6);
    expect(planCandidate.first.scheduledAt.minute, 30);
  });

  test('an active project deadline within the horizon is scheduled under its own category', () async {
    await enableMaster();
    await enable('notif.projectDeadlines');
    final created = _ok(await projectRepository.createProject(userId: 'u1', title: 'Ship the app'));
    await projectRepository.updateProject(created.copyWith(deadline: today.addDays(3)));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, hasLength(1));
    expect(schedule.single.preferenceKey, 'notif.projectDeadlines');
    expect(schedule.single.body, 'Ship the app');
  });

  test('a project deadline outside the 14-day horizon is not scheduled yet', () async {
    await enableMaster();
    await enable('notif.projectDeadlines');
    final created = _ok(await projectRepository.createProject(userId: 'u1', title: 'Far off'));
    await projectRepository.updateProject(created.copyWith(deadline: today.addDays(30)));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, isEmpty);
  });

  test("an archived project's deadline is not scheduled", () async {
    await enableMaster();
    await enable('notif.projectDeadlines');
    final created = _ok(await projectRepository.createProject(userId: 'u1', title: 'Shelved'));
    await projectRepository.updateProject(created.copyWith(deadline: today.addDays(2), status: ProjectStatus.archived));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule, isEmpty);
  });

  test('results are sorted by time, earliest first', () async {
    await enableMaster();
    await enable('notif.taskReminders');
    final later = _ok(await taskRepository.createTask(userId: 'u1', title: 'Later', dueDate: today.addDays(2).toIso()));
    await taskRepository.updateTask(later.copyWith(dueTime: '09:00'));
    final earlier = _ok(await taskRepository.createTask(userId: 'u1', title: 'Earlier', dueDate: today.addDays(1).toIso()));
    await taskRepository.updateTask(earlier.copyWith(dueTime: '09:00'));

    final schedule = await scheduler.buildSchedule('u1');
    expect(schedule.map((c) => c.body).toList(), ['Earlier', 'Later']);
  });
}
