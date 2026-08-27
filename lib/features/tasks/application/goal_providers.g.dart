// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalRepository)
const goalRepositoryProvider = GoalRepositoryProvider._();

final class GoalRepositoryProvider
    extends $FunctionalProvider<GoalRepository, GoalRepository, GoalRepository>
    with $Provider<GoalRepository> {
  const GoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalRepository create(Ref ref) {
    return goalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalRepository>(value),
    );
  }
}

String _$goalRepositoryHash() => r'562b5ee583074598ac6309eb804ea9149805704e';

/// `tasks/`'s own `PlanRepository` instance for §12.3's "linked plans"
/// list — never `lib/features/plans/`'s own provider (rule 4), same
/// pattern as `library/`'s `libraryPlanRepositoryProvider`.

@ProviderFor(goalPlanRepository)
const goalPlanRepositoryProvider = GoalPlanRepositoryProvider._();

/// `tasks/`'s own `PlanRepository` instance for §12.3's "linked plans"
/// list — never `lib/features/plans/`'s own provider (rule 4), same
/// pattern as `library/`'s `libraryPlanRepositoryProvider`.

final class GoalPlanRepositoryProvider
    extends $FunctionalProvider<PlanRepository, PlanRepository, PlanRepository>
    with $Provider<PlanRepository> {
  /// `tasks/`'s own `PlanRepository` instance for §12.3's "linked plans"
  /// list — never `lib/features/plans/`'s own provider (rule 4), same
  /// pattern as `library/`'s `libraryPlanRepositoryProvider`.
  const GoalPlanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalPlanRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalPlanRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlanRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanRepository create(Ref ref) {
    return goalPlanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanRepository>(value),
    );
  }
}

String _$goalPlanRepositoryHash() =>
    r'335e63d1cb44c41a7d7562253e83066ec89efffe';

@ProviderFor(plansForGoal)
const plansForGoalProvider = PlansForGoalFamily._();

final class PlansForGoalProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const PlansForGoalProvider._({
    required PlansForGoalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'plansForGoalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$plansForGoalHash();

  @override
  String toString() {
    return r'plansForGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    final argument = this.argument as String;
    return plansForGoal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlansForGoalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plansForGoalHash() => r'4ab7f6a56bf15078af4ac9689a64751dd7e3268e';

final class PlansForGoalFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppPlan>>, String> {
  const PlansForGoalFamily._()
    : super(
        retry: null,
        name: r'plansForGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlansForGoalProvider call(String goalId) =>
      PlansForGoalProvider._(argument: goalId, from: this);

  @override
  String toString() => r'plansForGoalProvider';
}

@ProviderFor(allGoals)
const allGoalsProvider = AllGoalsProvider._();

final class AllGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppGoal>>,
          List<AppGoal>,
          Stream<List<AppGoal>>
        >
    with $FutureModifier<List<AppGoal>>, $StreamProvider<List<AppGoal>> {
  const AllGoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allGoalsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppGoal>> create(Ref ref) {
    return allGoals(ref);
  }
}

String _$allGoalsHash() => r'52dd348883d17334951157ba78ef6739d17e0684';

@ProviderFor(goalById)
const goalByIdProvider = GoalByIdFamily._();

final class GoalByIdProvider
    extends
        $FunctionalProvider<AsyncValue<AppGoal?>, AppGoal?, Stream<AppGoal?>>
    with $FutureModifier<AppGoal?>, $StreamProvider<AppGoal?> {
  const GoalByIdProvider._({
    required GoalByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalByIdHash();

  @override
  String toString() {
    return r'goalByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppGoal?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppGoal?> create(Ref ref) {
    final argument = this.argument as String;
    return goalById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalByIdHash() => r'234350b400ac18e4469fd00371cad45cd211faf8';

final class GoalByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppGoal?>, String> {
  const GoalByIdFamily._()
    : super(
        retry: null,
        name: r'goalByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalByIdProvider call(String goalId) =>
      GoalByIdProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalByIdProvider';
}

@ProviderFor(goalContributions)
const goalContributionsProvider = GoalContributionsFamily._();

final class GoalContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppGoalContribution>>,
          List<AppGoalContribution>,
          Stream<List<AppGoalContribution>>
        >
    with
        $FutureModifier<List<AppGoalContribution>>,
        $StreamProvider<List<AppGoalContribution>> {
  const GoalContributionsProvider._({
    required GoalContributionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalContributionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalContributionsHash();

  @override
  String toString() {
    return r'goalContributionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppGoalContribution>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppGoalContribution>> create(Ref ref) {
    final argument = this.argument as String;
    return goalContributions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalContributionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalContributionsHash() => r'20917b0bc7c1b7006699b209ca415c7e7bd7bfcd';

final class GoalContributionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppGoalContribution>>, String> {
  const GoalContributionsFamily._()
    : super(
        retry: null,
        name: r'goalContributionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalContributionsProvider call(String goalId) =>
      GoalContributionsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalContributionsProvider';
}

@ProviderFor(goalMilestones)
const goalMilestonesProvider = GoalMilestonesFamily._();

final class GoalMilestonesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppGoalMilestone>>,
          List<AppGoalMilestone>,
          Stream<List<AppGoalMilestone>>
        >
    with
        $FutureModifier<List<AppGoalMilestone>>,
        $StreamProvider<List<AppGoalMilestone>> {
  const GoalMilestonesProvider._({
    required GoalMilestonesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalMilestonesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalMilestonesHash();

  @override
  String toString() {
    return r'goalMilestonesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppGoalMilestone>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppGoalMilestone>> create(Ref ref) {
    final argument = this.argument as String;
    return goalMilestones(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalMilestonesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalMilestonesHash() => r'f82a1c13e31f0d57974e16a8b6931a8d534aa290';

final class GoalMilestonesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppGoalMilestone>>, String> {
  const GoalMilestonesFamily._()
    : super(
        retry: null,
        name: r'goalMilestonesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalMilestonesProvider call(String goalId) =>
      GoalMilestonesProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalMilestonesProvider';
}
