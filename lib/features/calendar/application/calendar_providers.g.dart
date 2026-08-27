// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
const eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<EventRepository, EventRepository, EventRepository>
    with $Provider<EventRepository> {
  const EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'b38671ec7c5d1819a6e910a8f42dfa7aa8c8fe05';

/// §14.5: one range query per visible period.

@ProviderFor(eventsInRange)
const eventsInRangeProvider = EventsInRangeFamily._();

/// §14.5: one range query per visible period.

final class EventsInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppEvent>>,
          List<AppEvent>,
          Stream<List<AppEvent>>
        >
    with $FutureModifier<List<AppEvent>>, $StreamProvider<List<AppEvent>> {
  /// §14.5: one range query per visible period.
  const EventsInRangeProvider._({
    required EventsInRangeFamily super.from,
    required (CivilDate, CivilDate) super.argument,
  }) : super(
         retry: null,
         name: r'eventsInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsInRangeHash();

  @override
  String toString() {
    return r'eventsInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<AppEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppEvent>> create(Ref ref) {
    final argument = this.argument as (CivilDate, CivilDate);
    return eventsInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsInRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsInRangeHash() => r'b5b4d55796e480fc0893d01aafccffde36a97afd';

/// §14.5: one range query per visible period.

final class EventsInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<AppEvent>>,
          (CivilDate, CivilDate)
        > {
  const EventsInRangeFamily._()
    : super(
        retry: null,
        name: r'eventsInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §14.5: one range query per visible period.

  EventsInRangeProvider call(CivilDate from, CivilDate through) =>
      EventsInRangeProvider._(argument: (from, through), from: this);

  @override
  String toString() => r'eventsInRangeProvider';
}

@ProviderFor(eventById)
const eventByIdProvider = EventByIdFamily._();

final class EventByIdProvider
    extends
        $FunctionalProvider<AsyncValue<AppEvent?>, AppEvent?, Stream<AppEvent?>>
    with $FutureModifier<AppEvent?>, $StreamProvider<AppEvent?> {
  const EventByIdProvider._({
    required EventByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventByIdHash();

  @override
  String toString() {
    return r'eventByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AppEvent?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppEvent?> create(Ref ref) {
    final argument = this.argument as String;
    return eventById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventByIdHash() => r'5864d888524a5e1d02e67f165a66e31ecd8f1846';

final class EventByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AppEvent?>, String> {
  const EventByIdFamily._()
    : super(
        retry: null,
        name: r'eventByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventByIdProvider call(String eventId) =>
      EventByIdProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventByIdProvider';
}
