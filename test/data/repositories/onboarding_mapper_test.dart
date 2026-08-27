import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/data/repositories/onboarding_mapper.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';

void main() {
  late AppDatabase database;
  late TaskRepository tasks;
  late PlanRepository plans;
  late ProjectRepository projects;
  late LibraryItemRepository library;
  late RulesBasedOnboardingMapper mapper;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    tasks = TaskRepository(TaskDao(database));
    plans = PlanRepository(PlanDao(database), ActivityLogDao(database));
    projects = ProjectRepository(ProjectDao(database));
    library = LibraryItemRepository(LibraryItemDao(database));
    mapper = RulesBasedOnboardingMapper(
      taskRepository: tasks,
      planRepository: plans,
      projectRepository: projects,
      libraryItemRepository: library,
    );
  });

  tearDown(() => database.close());

  test('routes each answer to the right kind of real record', () async {
    await mapper.apply('u1', [
      const OnboardingAnswer(question: OnboardingQuestion.startDoing, text: 'Drink more water'),
      const OnboardingAnswer(question: OnboardingQuestion.dailyWeekly, text: 'Morning workout'),
      const OnboardingAnswer(question: OnboardingQuestion.currentlyWorking, text: 'Kitchen renovation'),
      const OnboardingAnswer(question: OnboardingQuestion.readWatch, text: 'Dune', mediaType: MediaType.book),
      const OnboardingAnswer(question: OnboardingQuestion.readWatch, text: 'Arrival', mediaType: MediaType.film),
    ]);

    final somedayTasks = await tasks.watchSomeday('u1').first;
    expect(somedayTasks.map((t) => t.title), contains('Drink more water'));

    final habits = await plans.watchHabits('u1').first;
    expect(habits.map((p) => p.title), contains('Morning workout'));

    final createdProjects = await projects.watchAll('u1').first;
    expect(createdProjects.map((p) => p.title), contains('Kitchen renovation'));

    final books = await library.watchAll('u1', MediaType.book).first;
    final films = await library.watchAll('u1', MediaType.film).first;
    expect(books.map((i) => i.title), contains('Dune'));
    expect(films.map((i) => i.title), contains('Arrival'));
  });

  test('blank answers are skipped, not turned into empty-titled records', () async {
    await mapper.apply('u1', [
      const OnboardingAnswer(question: OnboardingQuestion.startDoing, text: '   '),
    ]);

    final somedayTasks = await tasks.watchSomeday('u1').first;
    expect(somedayTasks, isEmpty);
  });
}
