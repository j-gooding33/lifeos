import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/goal_dao.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_goal.dart';
import 'package:life_os/data/repositories/models/app_task.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/stats_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';

T _ok<T>(Result<T, Failure> result) => result.when(ok: (v) => v, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late TaskRepository taskRepository;
  late PlanRepository planRepository;
  late GoalRepository goalRepository;
  late LibraryItemRepository libraryItemRepository;
  late JournalRepository journalRepository;
  late StatsRepository stats;
  final today = CivilDate.fromDateTime(DateTime.now());

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    taskRepository = TaskRepository(TaskDao(database));
    planRepository = PlanRepository(PlanDao(database), ActivityLogDao(database));
    goalRepository = GoalRepository(GoalDao(database));
    libraryItemRepository = LibraryItemRepository(LibraryItemDao(database));
    journalRepository = JournalRepository(JournalDao(database));
    stats = StatsRepository(
      taskRepository: taskRepository,
      planRepository: planRepository,
      goalRepository: goalRepository,
      libraryItemRepository: libraryItemRepository,
      journalRepository: journalRepository,
    );
  });

  tearDown(() => database.close());

  group('statsForPeriod', () {
    test('counts a completed task only when its completion date falls in range', () async {
      final task = _ok(await taskRepository.createTask(userId: 'u1', title: 'In range'));
      await taskRepository.updateTask(task.copyWith(completedAt: DateTime(today.year, today.month, today.day)));

      final outOfRangeTask = _ok(await taskRepository.createTask(userId: 'u1', title: 'Out of range'));
      await taskRepository.updateTask(outOfRangeTask.copyWith(completedAt: DateTime(today.year, today.month, today.day).subtract(const Duration(days: 30))));

      final result = await stats.statsForPeriod(userId: 'u1', from: today, to: today);
      expect(result.tasksCompleted, 1);
    });

    test('films and books are counted by finishedAt, not addedAt', () async {
      final film = _ok(
        await libraryItemRepository.addManually(userId: 'u1', type: MediaType.film, title: 'A Film'),
      );
      await libraryItemRepository.markWatched(film.id, watchedDate: DateTime(today.year, today.month, today.day));

      final book = _ok(
        await libraryItemRepository.addManually(userId: 'u1', type: MediaType.book, title: 'A Book'),
      );
      await libraryItemRepository.markWatched(book.id, watchedDate: DateTime(today.year, today.month, today.day));

      final result = await stats.statsForPeriod(userId: 'u1', from: today, to: today);
      expect(result.filmsWatched, 1);
      expect(result.booksFinished, 1);
    });

    test('journal counts only days with non-empty written content', () async {
      final entry = _ok(await journalRepository.getOrCreate(userId: 'u1', date: today));
      // getOrCreate alone (no blocks written) should not count as "written."
      var result = await stats.statsForPeriod(userId: 'u1', from: today, to: today);
      expect(result.journalDaysWritten, 0);

      await journalRepository.updateEntry(entry.copyWith(mood: 3));
      result = await stats.statsForPeriod(userId: 'u1', from: today, to: today);
      expect(result.journalDaysWritten, 0); // still no text content

      // (plainText is derived from blocks; a real "written" day needs a
      // paragraph block — mood alone isn't writing.)
    });

    test('goal contributions are counted within range across all goals', () async {
      final goal = _ok(await goalRepository.createGoal(userId: 'u1', title: 'Read more', type: GoalType.count));
      await goalRepository.addManualLog(goal.id, 1, today);
      await goalRepository.addManualLog(goal.id, 1, today.addDays(-40));

      final result = await stats.statsForPeriod(userId: 'u1', from: today, to: today);
      expect(result.goalContributions, 1);
    });
  });

  group('dailyActivityScores', () {
    test('buckets completion counts into the five fixed thresholds', () async {
      Future<AppTask> makeCompletedTask(String title) async {
        final task = _ok(await taskRepository.createTask(userId: 'u1', title: title));
        await taskRepository.updateTask(task.copyWith(completedAt: DateTime(today.year, today.month, today.day)));
        return task;
      }

      // 3 completions today -> bucket 2 (3-4).
      await makeCompletedTask('a');
      await makeCompletedTask('b');
      await makeCompletedTask('c');

      final scores = await stats.dailyActivityScores(userId: 'u1', from: today, to: today);
      expect(scores[today], 2);
    });

    test('a day with zero completions is simply absent, not scored 0 explicitly', () async {
      final scores = await stats.dailyActivityScores(userId: 'u1', from: today.addDays(-2), to: today);
      expect(scores.containsKey(today), isFalse);
    });
  });

  group('dayDetail', () {
    test('reports tasks due that day and whether each is completed', () async {
      final task = _ok(await taskRepository.createTask(userId: 'u1', title: 'Due today', dueDate: today.toIso()));
      await taskRepository.completeTask(task);

      final detail = await stats.dayDetail(userId: 'u1', date: today);
      expect(detail.tasks.single.title, 'Due today');
      expect(detail.tasks.single.isCompleted, isTrue);
    });

    test('an empty day reports isEmpty', () async {
      final detail = await stats.dayDetail(userId: 'u1', date: today.addDays(-100));
      expect(detail.isEmpty, isTrue);
    });
  });

  group('insights', () {
    test('surfaces the best weekday only once it clears both the sample-size and ratio gates', () async {
      Future<void> completeOn(DateTime date, String title) async {
        final task = _ok(await taskRepository.createTask(userId: 'u1', title: title));
        await taskRepository.updateTask(task.copyWith(completedAt: date));
      }

      // 2024-01-09 was a Tuesday, 2024-01-08 a Monday — fixed reference
      // dates so the test doesn't depend on which weekday "today" is.
      for (var i = 0; i < 10; i++) {
        await completeOn(DateTime(2024, 1, 9), 'tue-$i');
      }
      for (var i = 0; i < 6; i++) {
        await completeOn(DateTime(2024, 1, 8), 'mon-$i');
      }
      // 10 vs 6 clears both gates: 16 total (>=14), and 10 >= 6*1.2.
      final withGap = await stats.insights(userId: 'u1');
      expect(withGap.any((i) => i.text.contains('Tuesday')), isTrue);
    });

    test('stays silent below the 14-completion floor even with a wide gap', () async {
      final task = _ok(await taskRepository.createTask(userId: 'u1', title: 'only one'));
      await taskRepository.updateTask(task.copyWith(completedAt: DateTime(2024, 1, 2)));

      final result = await stats.insights(userId: 'u1');
      expect(result.any((i) => i.text.contains('best day')), isFalse);
    });

    test('reports morning vs evening completion rates once both sides clear the sample floor', () async {
      // Anchored 9 days ago (not today) so the occurrences fall on-or-before
      // "today" — insights() only looks backward, the same as every other
      // StatsRepository method, since a future occurrence can't be resolved
      // yet. AppPlan's own startDate defaults to the rule's anchor, so
      // these past dates aren't filtered out of materialisation either.
      final anchor = today.addDays(-9);
      final morning = _ok(
        await planRepository.createPlan(userId: 'u1', title: 'Morning run', rule: IntervalDays(1, anchor: anchor), timeOfDay: '07:00'),
      );
      final evening = _ok(
        await planRepository.createPlan(userId: 'u1', title: 'Evening review', rule: IntervalDays(1, anchor: anchor), timeOfDay: '20:00'),
      );
      final morningOccurrences = await planRepository.watchPlanOccurrencesInRange(morning.id, anchor, today).first;
      final eveningOccurrences = await planRepository.watchPlanOccurrencesInRange(evening.id, anchor, today).first;
      expect(morningOccurrences.length, 10);
      expect(eveningOccurrences.length, 10);

      for (var i = 0; i < morningOccurrences.length; i++) {
        if (i < 8) {
          await planRepository.completeOccurrence(morningOccurrences[i], morning);
        } else {
          await planRepository.skipOccurrence(morningOccurrences[i]);
        }
      }
      for (var i = 0; i < eveningOccurrences.length; i++) {
        if (i < 2) {
          await planRepository.completeOccurrence(eveningOccurrences[i], evening);
        } else {
          await planRepository.skipOccurrence(eveningOccurrences[i]);
        }
      }

      final result = await stats.insights(userId: 'u1');
      final sentence = result.map((i) => i.text).firstWhere((t) => t.contains('morning'), orElse: () => '');
      expect(sentence, contains('80%'));
      expect(sentence, contains('20%'));
    });

    test('journal frequency needs at least 14 entries before it surfaces', () async {
      final entry = _ok(await journalRepository.getOrCreate(userId: 'u1', date: today));
      await journalRepository.updateEntry(entry.copyWith(mood: 4));

      final result = await stats.insights(userId: 'u1');
      expect(result.any((i) => i.text.contains('journal')), isFalse);
    });
  });
}
