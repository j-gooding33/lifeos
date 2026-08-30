// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'briefing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Own instance rather than `calendar/`'s provider — same rule-4 reason
/// as every other cross-feature repository in `home/`.

@ProviderFor(briefingEventRepository)
const briefingEventRepositoryProvider = BriefingEventRepositoryProvider._();

/// Own instance rather than `calendar/`'s provider — same rule-4 reason
/// as every other cross-feature repository in `home/`.

final class BriefingEventRepositoryProvider
    extends
        $FunctionalProvider<EventRepository, EventRepository, EventRepository>
    with $Provider<EventRepository> {
  /// Own instance rather than `calendar/`'s provider — same rule-4 reason
  /// as every other cross-feature repository in `home/`.
  const BriefingEventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'briefingEventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$briefingEventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventRepository create(Ref ref) {
    return briefingEventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepository>(value),
    );
  }
}

String _$briefingEventRepositoryHash() =>
    r'67f8b73ed15fc73b66fac83a33dcecf29187610e';

@ProviderFor(briefing)
const briefingProvider = BriefingFamily._();

final class BriefingProvider
    extends
        $FunctionalProvider<
          AsyncValue<BriefingData>,
          BriefingData,
          FutureOr<BriefingData>
        >
    with $FutureModifier<BriefingData>, $FutureProvider<BriefingData> {
  const BriefingProvider._({
    required BriefingFamily super.from,
    required BriefingPeriod super.argument,
  }) : super(
         retry: null,
         name: r'briefingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$briefingHash();

  @override
  String toString() {
    return r'briefingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BriefingData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BriefingData> create(Ref ref) {
    final argument = this.argument as BriefingPeriod;
    return briefing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BriefingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$briefingHash() => r'c622a58604fe1d3f0caa23d449cdff051a725be3';

final class BriefingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BriefingData>, BriefingPeriod> {
  const BriefingFamily._()
    : super(
        retry: null,
        name: r'briefingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BriefingProvider call(BriefingPeriod period) =>
      BriefingProvider._(argument: period, from: this);

  @override
  String toString() => r'briefingProvider';
}
