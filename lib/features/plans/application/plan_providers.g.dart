// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planRepository)
const planRepositoryProvider = PlanRepositoryProvider._();

final class PlanRepositoryProvider
    extends $FunctionalProvider<PlanRepository, PlanRepository, PlanRepository>
    with $Provider<PlanRepository> {
  const PlanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlanRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlanRepository create(Ref ref) {
    return planRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlanRepository>(value),
    );
  }
}

String _$planRepositoryHash() => r'3752ed5b48d8c7bb4331d1db79c7bb8e4dea832c';

@ProviderFor(activePlans)
const activePlansProvider = ActivePlansProvider._();

final class ActivePlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const ActivePlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePlansHash();

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    return activePlans(ref);
  }
}

String _$activePlansHash() => r'194e699fef557c6e677528c5c702267f7f570e33';

@ProviderFor(habitPlans)
const habitPlansProvider = HabitPlansProvider._();

final class HabitPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const HabitPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitPlansHash();

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    return habitPlans(ref);
  }
}

String _$habitPlansHash() => r'e5019a5215f607a186a33b2d37a383ba384d271b';

@ProviderFor(pausedPlans)
const pausedPlansProvider = PausedPlansProvider._();

final class PausedPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const PausedPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pausedPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pausedPlansHash();

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    return pausedPlans(ref);
  }
}

String _$pausedPlansHash() => r'f83f82a73808c663d9580e4e14729d2932844909';

@ProviderFor(archivedPlans)
const archivedPlansProvider = ArchivedPlansProvider._();

final class ArchivedPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppPlan>>,
          List<AppPlan>,
          Stream<List<AppPlan>>
        >
    with $FutureModifier<List<AppPlan>>, $StreamProvider<List<AppPlan>> {
  const ArchivedPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedPlansHash();

  @$internal
  @override
  $StreamProviderElement<List<AppPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppPlan>> create(Ref ref) {
    return archivedPlans(ref);
  }
}

String _$archivedPlansHash() => r'b18735175b763608e265edb2683e614cea67f4bb';

@ProviderFor(planById)
const planByIdProvider = PlanByIdFamily._();

final class PlanByIdProvider
    extends
        $FunctionalProvider<AsyncValue<AppPlan?>, AppPlan?, Stream<AppPlan?>>
    with $FutureModifier<AppPlan?>, $StreamProvider<AppPlan?> {
  const PlanByIdProvider._({
    required PlanByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'planByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planByIdHash();

  @override
  String toString() {
    return r'planByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppPlan?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppPlan?> create(Ref ref) {
    final argument = this.argument as String;
    return planById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planByIdHash() => r'28e8dabdd09bb821306f751eddbbb349b2228a7d';

final class PlanByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppPlan?>, String> {
  const PlanByIdFamily._()
    : super(
        retry: null,
        name: r'planByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlanByIdProvider call(String planId) =>
      PlanByIdProvider._(argument: planId, from: this);

  @override
  String toString() => r'planByIdProvider';
}

@ProviderFor(upcomingOccurrences)
const upcomingOccurrencesProvider = UpcomingOccurrencesFamily._();

final class UpcomingOccurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppOccurrence>>,
          List<AppOccurrence>,
          Stream<List<AppOccurrence>>
        >
    with
        $FutureModifier<List<AppOccurrence>>,
        $StreamProvider<List<AppOccurrence>> {
  const UpcomingOccurrencesProvider._({
    required UpcomingOccurrencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'upcomingOccurrencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$upcomingOccurrencesHash();

  @override
  String toString() {
    return r'upcomingOccurrencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppOccurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppOccurrence>> create(Ref ref) {
    final argument = this.argument as String;
    return upcomingOccurrences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingOccurrencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$upcomingOccurrencesHash() =>
    r'cffc6e18694d5f40a0b45ee8fa9363309664cec7';

final class UpcomingOccurrencesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<AppOccurrence>>, String> {
  const UpcomingOccurrencesFamily._()
    : super(
        retry: null,
        name: r'upcomingOccurrencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpcomingOccurrencesProvider call(String planId) =>
      UpcomingOccurrencesProvider._(argument: planId, from: this);

  @override
  String toString() => r'upcomingOccurrencesProvider';
}

@ProviderFor(historyOccurrences)
const historyOccurrencesProvider = HistoryOccurrencesFamily._();

final class HistoryOccurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppOccurrence>>,
          List<AppOccurrence>,
          Stream<List<AppOccurrence>>
        >
    with
        $FutureModifier<List<AppOccurrence>>,
        $StreamProvider<List<AppOccurrence>> {
  const HistoryOccurrencesProvider._({
    required HistoryOccurrencesFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'historyOccurrencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyOccurrencesHash();

  @override
  String toString() {
    return r'historyOccurrencesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppOccurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppOccurrence>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return historyOccurrences(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryOccurrencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyOccurrencesHash() =>
    r'475feb11d32e7171b5ea9caf49f241c7e43cac58';

final class HistoryOccurrencesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppOccurrence>>,
          (String, {int limit})
        > {
  const HistoryOccurrencesFamily._()
    : super(
        retry: null,
        name: r'historyOccurrencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HistoryOccurrencesProvider call(String planId, {int limit = 20}) =>
      HistoryOccurrencesProvider._(
        argument: (planId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'historyOccurrencesProvider';
}

@ProviderFor(planStats)
const planStatsProvider = PlanStatsFamily._();

final class PlanStatsProvider
    extends
        $FunctionalProvider<AsyncValue<PlanStats>, PlanStats, Stream<PlanStats>>
    with $FutureModifier<PlanStats>, $StreamProvider<PlanStats> {
  const PlanStatsProvider._({
    required PlanStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'planStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planStatsHash();

  @override
  String toString() {
    return r'planStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PlanStats> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PlanStats> create(Ref ref) {
    final argument = this.argument as String;
    return planStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planStatsHash() => r'faffceb334db1b753bb24fdca5eecfc32e9f2dba';

final class PlanStatsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PlanStats>, String> {
  const PlanStatsFamily._()
    : super(
        retry: null,
        name: r'planStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlanStatsProvider call(String planId) =>
      PlanStatsProvider._(argument: planId, from: this);

  @override
  String toString() => r'planStatsProvider';
}

@ProviderFor(todayOccurrenceForPlan)
const todayOccurrenceForPlanProvider = TodayOccurrenceForPlanFamily._();

final class TodayOccurrenceForPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppOccurrence?>,
          AppOccurrence?,
          Stream<AppOccurrence?>
        >
    with $FutureModifier<AppOccurrence?>, $StreamProvider<AppOccurrence?> {
  const TodayOccurrenceForPlanProvider._({
    required TodayOccurrenceForPlanFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todayOccurrenceForPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayOccurrenceForPlanHash();

  @override
  String toString() {
    return r'todayOccurrenceForPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppOccurrence?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppOccurrence?> create(Ref ref) {
    final argument = this.argument as String;
    return todayOccurrenceForPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayOccurrenceForPlanProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayOccurrenceForPlanHash() =>
    r'245daddbfa0f7ce860461d38959396399bcb7b13';

final class TodayOccurrenceForPlanFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppOccurrence?>, String> {
  const TodayOccurrenceForPlanFamily._()
    : super(
        retry: null,
        name: r'todayOccurrenceForPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TodayOccurrenceForPlanProvider call(String planId) =>
      TodayOccurrenceForPlanProvider._(argument: planId, from: this);

  @override
  String toString() => r'todayOccurrenceForPlanProvider';
}

@ProviderFor(occurrenceById)
const occurrenceByIdProvider = OccurrenceByIdFamily._();

final class OccurrenceByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppOccurrence?>,
          AppOccurrence?,
          Stream<AppOccurrence?>
        >
    with $FutureModifier<AppOccurrence?>, $StreamProvider<AppOccurrence?> {
  const OccurrenceByIdProvider._({
    required OccurrenceByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'occurrenceByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$occurrenceByIdHash();

  @override
  String toString() {
    return r'occurrenceByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppOccurrence?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppOccurrence?> create(Ref ref) {
    final argument = this.argument as String;
    return occurrenceById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OccurrenceByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$occurrenceByIdHash() => r'2eb66648f44ac82c69104c8899aa7623dcde67aa';

final class OccurrenceByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppOccurrence?>, String> {
  const OccurrenceByIdFamily._()
    : super(
        retry: null,
        name: r'occurrenceByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OccurrenceByIdProvider call(String occurrenceId) =>
      OccurrenceByIdProvider._(argument: occurrenceId, from: this);

  @override
  String toString() => r'occurrenceByIdProvider';
}

@ProviderFor(planOccurrencesInRange)
const planOccurrencesInRangeProvider = PlanOccurrencesInRangeFamily._();

final class PlanOccurrencesInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppOccurrence>>,
          List<AppOccurrence>,
          Stream<List<AppOccurrence>>
        >
    with
        $FutureModifier<List<AppOccurrence>>,
        $StreamProvider<List<AppOccurrence>> {
  const PlanOccurrencesInRangeProvider._({
    required PlanOccurrencesInRangeFamily super.from,
    required (String, CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'planOccurrencesInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$planOccurrencesInRangeHash();

  @override
  String toString() {
    return r'planOccurrencesInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppOccurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppOccurrence>> create(Ref ref) {
    final argument = this.argument as (String, CivilDate, CivilDate);
    return planOccurrencesInRange(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanOccurrencesInRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$planOccurrencesInRangeHash() =>
    r'f273783d6f3f9ee48d6973720ab8c529fdb3a899';

final class PlanOccurrencesInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppOccurrence>>,
          (String, CivilDate, CivilDate)
        > {
  const PlanOccurrencesInRangeFamily._()
    : super(
        retry: null,
        name: r'planOccurrencesInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlanOccurrencesInRangeProvider call(
    String planId,
    CivilDate from,
    CivilDate through,
  ) => PlanOccurrencesInRangeProvider._(
    argument: (planId, from, through),
    from: this,
  );

  @override
  String toString() => r'planOccurrencesInRangeProvider';
}

/// §14.5: one range query per visible calendar period, shared by every
/// unified-calendar view.

@ProviderFor(occurrencesInRange)
const occurrencesInRangeProvider = OccurrencesInRangeFamily._();

/// §14.5: one range query per visible calendar period, shared by every
/// unified-calendar view.

final class OccurrencesInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppOccurrence>>,
          List<AppOccurrence>,
          Stream<List<AppOccurrence>>
        >
    with
        $FutureModifier<List<AppOccurrence>>,
        $StreamProvider<List<AppOccurrence>> {
  /// §14.5: one range query per visible calendar period, shared by every
  /// unified-calendar view.
  const OccurrencesInRangeProvider._({
    required OccurrencesInRangeFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'occurrencesInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$occurrencesInRangeHash();

  @override
  String toString() {
    return r'occurrencesInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppOccurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppOccurrence>> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return occurrencesInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is OccurrencesInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$occurrencesInRangeHash() =>
    r'207745a2eeb3fcabb6ca2a97c8b7af281107aabc';

/// §14.5: one range query per visible calendar period, shared by every
/// unified-calendar view.

final class OccurrencesInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppOccurrence>>,
          (CivilDate, CivilDate)
        > {
  const OccurrencesInRangeFamily._()
    : super(
        retry: null,
        name: r'occurrencesInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §14.5: one range query per visible calendar period, shared by every
  /// unified-calendar view.

  OccurrencesInRangeProvider call(CivilDate from, CivilDate through) =>
      OccurrencesInRangeProvider._(argument: (from, through), from: this);

  @override
  String toString() => r'occurrencesInRangeProvider';
}

/// §9.5 trigger: run once whenever the Plans list is opened, so occurrence
/// generation and the missed sweep stay current without a true midnight
/// background job (see DECISIONS.md).

@ProviderFor(plansMaintenance)
const plansMaintenanceProvider = PlansMaintenanceProvider._();

/// §9.5 trigger: run once whenever the Plans list is opened, so occurrence
/// generation and the missed sweep stay current without a true midnight
/// background job (see DECISIONS.md).

final class PlansMaintenanceProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// §9.5 trigger: run once whenever the Plans list is opened, so occurrence
  /// generation and the missed sweep stay current without a true midnight
  /// background job (see DECISIONS.md).
  const PlansMaintenanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plansMaintenanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plansMaintenanceHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return plansMaintenance(ref);
  }
}

String _$plansMaintenanceHash() => r'846a85d806721ad55200ed705669a58b79f4cf06';
