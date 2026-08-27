import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/project_dao.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/data/repositories/onboarding_mapper.dart';
import 'package:life_os/data/repositories/onboarding_repository.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/project_repository.dart';
import 'package:life_os/data/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

/// Builds its own repository instances straight from their DAOs (all under
/// `data/`, never another feature's `application/` folder) rather than
/// importing Tasks/Plans/Library's own provider files — CLAUDE.md rule 4,
/// "features do not import features". They wrap the same `AppDatabase`
/// singleton those features' own repositories do, so this is a second
/// stateless handle onto the same data, not a second source of truth.
@Riverpod(keepAlive: true)
ProjectRepository projectRepository(Ref ref) {
  return ProjectRepository(ProjectDao(ref.watch(appDatabaseProvider)));
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepository(ref.watch(preferencesRepositoryProvider));
}

@Riverpod(keepAlive: true)
OnboardingMapper onboardingMapper(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return RulesBasedOnboardingMapper(
    taskRepository: TaskRepository(TaskDao(database)),
    planRepository: PlanRepository(PlanDao(database), ActivityLogDao(database)),
    projectRepository: ref.watch(projectRepositoryProvider),
    libraryItemRepository: LibraryItemRepository(LibraryItemDao(database)),
  );
}

@riverpod
Stream<bool> hasOnboarded(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(onboardingRepositoryProvider).watchHasOnboarded(userId);
}

/// Runs the mapper, persists the answers, and flips [hasOnboardedProvider]
/// — the one call site the onboarding screen needs.
Future<void> completeOnboarding(WidgetRef ref, List<OnboardingAnswer> answers) async {
  final userId = await ref.read(currentUserIdProvider.future);
  final repository = ref.read(onboardingRepositoryProvider);
  await repository.saveAnswers(userId, answers);
  await ref.read(onboardingMapperProvider).apply(userId, answers);
  await repository.setHasOnboarded(userId, value: true);
}
