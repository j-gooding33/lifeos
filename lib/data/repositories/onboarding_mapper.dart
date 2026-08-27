import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/scheduling/recurrence_rule.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';

/// Turns onboarding answers into real records. An interface rather than a
/// concrete class the screen calls directly, so a future AI-based parser
/// (free text → richer structured intent, e.g. "every weekday" → a real
/// weekly rule instead of always-daily) can be swapped in at the provider
/// wiring point without the onboarding screen changing at all.
// ignore: one_member_abstracts
abstract class OnboardingMapper {
  Future<void> apply(String userId, List<OnboardingAnswer> answers);
}

/// The only implementation today — no NLP, just "which question was this
/// answer to" (§8's brief: "build ... a local rules-based mapper; leave a
/// clean interface where an AI parser can be swapped in later").
class RulesBasedOnboardingMapper implements OnboardingMapper {
  const RulesBasedOnboardingMapper({
    required TaskRepository taskRepository,
    required PlanRepository planRepository,
    required ProjectRepository projectRepository,
    required LibraryItemRepository libraryItemRepository,
  }) : _tasks = taskRepository,
       _plans = planRepository,
       _projects = projectRepository,
       _library = libraryItemRepository;

  final TaskRepository _tasks;
  final PlanRepository _plans;
  final ProjectRepository _projects;
  final LibraryItemRepository _library;

  @override
  Future<void> apply(String userId, List<OnboardingAnswer> answers) async {
    for (final answer in answers) {
      final text = answer.text.trim();
      if (text.isEmpty) continue;
      switch (answer.question) {
        case OnboardingQuestion.startDoing:
          // A one-off intention (§8) — a Task.
          await _tasks.createTask(userId: userId, title: text);
        case OnboardingQuestion.dailyWeekly:
          // A recurring intention — a habit-kind Plan. No NLP to tell
          // "every day" from "every Monday" apart, so every answer here
          // becomes a daily rhythm; the user can edit it to a real weekly
          // one from the Plan itself once it exists.
          await _plans.createPlan(
            userId: userId,
            title: text,
            kind: PlanKind.habit,
            rule: IntervalDays(1, anchor: CivilDate.fromDateTime(DateTime.now())),
          );
        case OnboardingQuestion.currentlyWorking:
          // A longer effort — a Project.
          await _projects.createProject(userId: userId, title: text);
        case OnboardingQuestion.readWatch:
          // Media — a Library entry, film or book per the screen's toggle.
          await _library.addManually(userId: userId, type: answer.mediaType ?? MediaType.book, title: text);
      }
    }
  }
}
