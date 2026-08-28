// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Constructed straight from DAOs, not by importing Tasks/Plans/Goals/
/// Library/Journal's own provider files (CLAUDE.md rule 4) — same pattern
/// as `LNotesSection`/`resolveDomainColour`/`dataSettingsSearchRepository`.

@ProviderFor(statsRepository)
const statsRepositoryProvider = StatsRepositoryProvider._();

/// Constructed straight from DAOs, not by importing Tasks/Plans/Goals/
/// Library/Journal's own provider files (CLAUDE.md rule 4) — same pattern
/// as `LNotesSection`/`resolveDomainColour`/`dataSettingsSearchRepository`.

final class StatsRepositoryProvider
    extends
        $FunctionalProvider<StatsRepository, StatsRepository, StatsRepository>
    with $Provider<StatsRepository> {
  /// Constructed straight from DAOs, not by importing Tasks/Plans/Goals/
  /// Library/Journal's own provider files (CLAUDE.md rule 4) — same pattern
  /// as `LNotesSection`/`resolveDomainColour`/`dataSettingsSearchRepository`.
  const StatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepository create(Ref ref) {
    return statsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepository>(value),
    );
  }
}

String _$statsRepositoryHash() => r'5bca6a2be7f28d01c1855a0904e226c797803c9e';

@ProviderFor(periodStats)
const periodStatsProvider = PeriodStatsFamily._();

final class PeriodStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PeriodStats>,
          PeriodStats,
          FutureOr<PeriodStats>
        >
    with $FutureModifier<PeriodStats>, $FutureProvider<PeriodStats> {
  const PeriodStatsProvider._({
    required PeriodStatsFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'periodStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$periodStatsHash();

  @override
  String toString() {
    return r'periodStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PeriodStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PeriodStats> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return periodStats(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$periodStatsHash() => r'76a301a5bb45b693fe38ddef42110a2c004b41a1';

final class PeriodStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PeriodStats>,
          (CivilDate, CivilDate)
        > {
  const PeriodStatsFamily._()
    : super(
        retry: null,
        name: r'periodStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PeriodStatsProvider call(CivilDate from, CivilDate to) =>
      PeriodStatsProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'periodStatsProvider';
}

@ProviderFor(dailyActivityScores)
const dailyActivityScoresProvider = DailyActivityScoresFamily._();

final class DailyActivityScoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<CivilDate, int>>,
          Map<CivilDate, int>,
          FutureOr<Map<CivilDate, int>>
        >
    with
        $FutureModifier<Map<CivilDate, int>>,
        $FutureProvider<Map<CivilDate, int>> {
  const DailyActivityScoresProvider._({
    required DailyActivityScoresFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'dailyActivityScoresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyActivityScoresHash();

  @override
  String toString() {
    return r'dailyActivityScoresProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<CivilDate, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<CivilDate, int>> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return dailyActivityScores(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyActivityScoresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyActivityScoresHash() =>
    r'c943350dd51db3ef13e1f4a043c19fb1a6bfb81c';

final class DailyActivityScoresFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<CivilDate, int>>,
          (CivilDate, CivilDate)
        > {
  const DailyActivityScoresFamily._()
    : super(
        retry: null,
        name: r'dailyActivityScoresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DailyActivityScoresProvider call(CivilDate from, CivilDate to) =>
      DailyActivityScoresProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'dailyActivityScoresProvider';
}

@ProviderFor(datesWithCompletedMilestone)
const datesWithCompletedMilestoneProvider =
    DatesWithCompletedMilestoneFamily._();

final class DatesWithCompletedMilestoneProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<CivilDate>>,
          Set<CivilDate>,
          FutureOr<Set<CivilDate>>
        >
    with $FutureModifier<Set<CivilDate>>, $FutureProvider<Set<CivilDate>> {
  const DatesWithCompletedMilestoneProvider._({
    required DatesWithCompletedMilestoneFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'datesWithCompletedMilestoneProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$datesWithCompletedMilestoneHash();

  @override
  String toString() {
    return r'datesWithCompletedMilestoneProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Set<CivilDate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<CivilDate>> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return datesWithCompletedMilestone(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DatesWithCompletedMilestoneProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$datesWithCompletedMilestoneHash() =>
    r'904889aca3ef52fc4a36304248befdeefd7ca5e8';

final class DatesWithCompletedMilestoneFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Set<CivilDate>>,
          (CivilDate, CivilDate)
        > {
  const DatesWithCompletedMilestoneFamily._()
    : super(
        retry: null,
        name: r'datesWithCompletedMilestoneProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DatesWithCompletedMilestoneProvider call(CivilDate from, CivilDate to) =>
      DatesWithCompletedMilestoneProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'datesWithCompletedMilestoneProvider';
}

@ProviderFor(dayDetail)
const dayDetailProvider = DayDetailFamily._();

final class DayDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayDetail>,
          DayDetail,
          FutureOr<DayDetail>
        >
    with $FutureModifier<DayDetail>, $FutureProvider<DayDetail> {
  const DayDetailProvider._({
    required DayDetailFamily super.from,
    required CivilDate super.argument,
  }) : super(
         retry: null,
         name: r'dayDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayDetailHash();

  @override
  String toString() {
    return r'dayDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DayDetail> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DayDetail> create(Ref ref) {
    final argument = this.argument as CivilDate;
    return dayDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayDetailHash() => r'52073a90637cbf5a577481f40fc79f61c3627394';

final class DayDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DayDetail>, CivilDate> {
  const DayDetailFamily._()
    : super(
        retry: null,
        name: r'dayDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DayDetailProvider call(CivilDate date) =>
      DayDetailProvider._(argument: date, from: this);

  @override
  String toString() => r'dayDetailProvider';
}
