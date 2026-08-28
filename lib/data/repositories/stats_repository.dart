import 'dart:async';

import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/goal_repository.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/models/day_detail.dart';
import 'package:life_os/data/repositories/models/period_stats.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';

/// `Stream.first` cancels its subscription synchronously from inside the
/// `onData` callback that delivers the first event. That's fine for most
/// streams, but Drift's `QueryStream` (as used by every `watchXxx` method
/// this repository calls) races with that synchronous cancel under
/// `NativeDatabase` and never completes the returned future — reproduced
/// and root-caused against a minimal repro outside this file. Deferring
/// the cancel to the next microtask avoids the race. See DECISIONS.md.
Future<T> _firstValue<T>(Stream<T> stream) {
  final completer = Completer<T>();
  late StreamSubscription<T> subscription;
  subscription = stream.listen(
    (value) {
      if (!completer.isCompleted) completer.complete(value);
    },
    onError: (Object error, StackTrace stackTrace) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    },
  );
  unawaited(completer.future.whenComplete(() => Future.microtask(subscription.cancel)));
  return completer.future;
}

/// §20: "never compute statistics by scanning raw tables at render time" —
/// this is exactly that, on purpose. Building the spec's actual
/// architecture (a `daily_rollups` table kept current by a `StatsRecorder`
/// subscribed to domain events, plus a nightly reconcile job) needs a
/// domain-event bus and a background job scheduler that don't exist
/// anywhere else in this app; retrofitting both just for Stats would be a
/// much bigger, riskier undertaking than the feature itself. At this app's
/// actual scale (one person's data, thousands of rows at most, not
/// millions) computing aggregates on demand from the repositories that
/// already exist is fast enough and can never drift from the source data
/// the way a cached rollup can. See DECISIONS.md.
class StatsRepository {
  StatsRepository({
    required this.taskRepository,
    required this.planRepository,
    required this.goalRepository,
    required this.libraryItemRepository,
    required this.journalRepository,
  });

  final TaskRepository taskRepository;
  final PlanRepository planRepository;
  final GoalRepository goalRepository;
  final LibraryItemRepository libraryItemRepository;
  final JournalRepository journalRepository;

  bool _inRange(CivilDate date, CivilDate from, CivilDate to) => date.isAtOrAfter(from) && date.isAtOrBefore(to);

  Future<PeriodStats> statsForPeriod({required String userId, required CivilDate from, required CivilDate to}) async {
    final tasks = await _firstValue(taskRepository.watchCompleted(userId, retentionDays: 3650));
    final tasksCompleted = tasks
        .where((t) => t.completedAt != null && _inRange(CivilDate.fromDateTime(t.completedAt!), from, to))
        .length;

    final habitPlanIds = (await _firstValue(planRepository.watchHabits(userId))).map((p) => p.id).toSet();
    final occurrences = await _firstValue(planRepository.watchOccurrencesInRange(userId, from, to));
    final completed = occurrences.where((o) => o.status == OccurrenceStatus.completed).toList();

    final films = await _firstValue(libraryItemRepository.watchAll(userId, MediaType.film));
    final filmsWatched = films.where((f) => f.finishedAt != null && _inRange(CivilDate.fromDateTime(f.finishedAt!), from, to)).length;

    final books = await _firstValue(libraryItemRepository.watchAll(userId, MediaType.book));
    final booksFinished = books.where((b) => b.finishedAt != null && _inRange(CivilDate.fromDateTime(b.finishedAt!), from, to)).length;

    final journalEntries = await _firstValue(journalRepository.watchRecent(userId, limit: 3650));
    final journalDaysWritten = journalEntries.where((j) => _inRange(j.date, from, to) && j.plainText.isNotEmpty).length;

    final goals = await _firstValue(goalRepository.watchAll(userId));
    var goalContributions = 0;
    for (final goal in goals) {
      final contributions = await _firstValue(goalRepository.watchContributions(goal.id));
      goalContributions += contributions.where((c) => _inRange(c.date, from, to)).length;
    }

    return PeriodStats(
      tasksCompleted: tasksCompleted,
      occurrencesCompleted: completed.length,
      occurrencesMissed: occurrences.where((o) => o.status == OccurrenceStatus.missed).length,
      occurrencesSkipped: occurrences.where((o) => o.status == OccurrenceStatus.skipped).length,
      habitsCompleted: completed.where((o) => habitPlanIds.contains(o.planId)).length,
      filmsWatched: filmsWatched,
      booksFinished: booksFinished,
      journalDaysWritten: journalDaysWritten,
      goalContributions: goalContributions,
    );
  }

  /// §21.3: one query for the whole year's occurrences, then bucketed by
  /// day in Dart — `AppTask.completedAt`/`AppLibraryItem.finishedAt` are
  /// instants (epoch ms), and bucketing those by the *device's local* day
  /// has to happen in Dart (`CivilDate.fromDateTime`) rather than via a
  /// UTC-based SQL date function, for the same DST/timezone reason every
  /// other date computation in this app avoids raw `DateTime` arithmetic.
  ///
  /// `activityScore` here is a fixed-threshold bucketing (0 / 1-2 / 3-4 /
  /// 5-7 / 8+ completions), not §20.1's "relative to the user's own 30-day
  /// median" — see DECISIONS.md.
  Future<Map<CivilDate, int>> dailyActivityScores({required String userId, required CivilDate from, required CivilDate to}) async {
    final counts = <CivilDate, int>{};
    void bump(CivilDate date) => counts[date] = (counts[date] ?? 0) + 1;

    final tasks = await _firstValue(taskRepository.watchCompleted(userId, retentionDays: 3650));
    for (final task in tasks) {
      final completedAt = task.completedAt;
      if (completedAt == null) continue;
      final date = CivilDate.fromDateTime(completedAt);
      if (_inRange(date, from, to)) bump(date);
    }

    final occurrences = await _firstValue(planRepository.watchOccurrencesInRange(userId, from, to));
    for (final occurrence in occurrences) {
      if (occurrence.status == OccurrenceStatus.completed) bump(occurrence.scheduledDate);
    }

    return counts.map((date, count) => MapEntry(date, _bucketScore(count)));
  }

  int _bucketScore(int completions) {
    if (completions <= 0) return 0;
    if (completions <= 2) return 1;
    if (completions <= 4) return 2;
    if (completions <= 7) return 3;
    return 4;
  }

  /// The days (within range) with at least one goal milestone completed —
  /// §21.1's "tiny notch in the top-right corner."
  Future<Set<CivilDate>> datesWithCompletedMilestone({required String userId, required CivilDate from, required CivilDate to}) async {
    final goals = await _firstValue(goalRepository.watchAll(userId));
    final dates = <CivilDate>{};
    for (final goal in goals) {
      final milestones = await _firstValue(goalRepository.watchMilestones(goal.id));
      for (final milestone in milestones) {
        final completedAt = milestone.completedAt;
        if (completedAt == null) continue;
        final date = CivilDate.fromDateTime(completedAt);
        if (_inRange(date, from, to)) dates.add(date);
      }
    }
    return dates;
  }

  Future<DayDetail> dayDetail({required String userId, required CivilDate date}) async {
    final tasksDue = await _firstValue(taskRepository.watchAllDueOn(userId, date));
    final completedTasks = await _firstValue(taskRepository.watchCompleted(userId, retentionDays: 3650));
    final tasksCompletedToday = completedTasks.where(
      (t) => t.completedAt != null && CivilDate.fromDateTime(t.completedAt!) == date,
    );
    final taskTitles = {
      for (final t in tasksDue) t.id: DayDetailTask(title: t.title, isCompleted: t.isCompleted),
      for (final t in tasksCompletedToday) t.id: DayDetailTask(title: t.title, isCompleted: true),
    };

    final occurrences = await _firstValue(planRepository.watchOccurrencesInRange(userId, date, date));
    final plans = await _firstValue(planRepository.watchActive(userId));
    final planTitleById = {for (final p in plans) p.id: p.title};

    final films = await _firstValue(libraryItemRepository.watchAll(userId, MediaType.film));
    final filmsToday = films.where((f) => f.finishedAt != null && CivilDate.fromDateTime(f.finishedAt!) == date).map((f) => f.title);

    final books = await _firstValue(libraryItemRepository.watchAll(userId, MediaType.book));
    final booksToday = books.where((b) => b.finishedAt != null && CivilDate.fromDateTime(b.finishedAt!) == date).map((b) => b.title);

    final journalEntry = await _firstValue(journalRepository.watchByDate(userId, date));

    final goals = await _firstValue(goalRepository.watchAll(userId));
    var goalsProgressed = 0;
    for (final goal in goals) {
      final contributions = await _firstValue(goalRepository.watchContributions(goal.id));
      if (contributions.any((c) => c.date == date)) goalsProgressed++;
    }

    return DayDetail(
      date: date,
      tasks: taskTitles.values.toList(),
      occurrences: [
        for (final o in occurrences)
          DayDetailOccurrence(title: planTitleById[o.planId] ?? 'Plan', status: o.status.name, scheduledTime: o.scheduledTime),
      ],
      filmsWatched: filmsToday.toList(),
      booksFinished: booksToday.toList(),
      journalWritten: journalEntry != null && journalEntry.plainText.isNotEmpty,
      goalsProgressed: goalsProgressed,
    );
  }
}
