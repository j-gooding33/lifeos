// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(schoolRepository)
const schoolRepositoryProvider = SchoolRepositoryProvider._();

final class SchoolRepositoryProvider
    extends
        $FunctionalProvider<
          SchoolRepository,
          SchoolRepository,
          SchoolRepository
        >
    with $Provider<SchoolRepository> {
  const SchoolRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolRepositoryHash();

  @$internal
  @override
  $ProviderElement<SchoolRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SchoolRepository create(Ref ref) {
    return schoolRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchoolRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchoolRepository>(value),
    );
  }
}

String _$schoolRepositoryHash() => r'873b56a985e837b41abf7113be50da992c62bac7';

@ProviderFor(schoolProfile)
const schoolProfileProvider = SchoolProfileProvider._();

final class SchoolProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSchoolProfile?>,
          AppSchoolProfile?,
          Stream<AppSchoolProfile?>
        >
    with
        $FutureModifier<AppSchoolProfile?>,
        $StreamProvider<AppSchoolProfile?> {
  const SchoolProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolProfileHash();

  @$internal
  @override
  $StreamProviderElement<AppSchoolProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSchoolProfile?> create(Ref ref) {
    return schoolProfile(ref);
  }
}

String _$schoolProfileHash() => r'd66208e8f04c5c24caac53c1bb493129a842937a';

@ProviderFor(schoolLessons)
const schoolLessonsProvider = SchoolLessonsProvider._();

final class SchoolLessonsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppSchoolLesson>>,
          List<AppSchoolLesson>,
          Stream<List<AppSchoolLesson>>
        >
    with
        $FutureModifier<List<AppSchoolLesson>>,
        $StreamProvider<List<AppSchoolLesson>> {
  const SchoolLessonsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolLessonsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolLessonsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppSchoolLesson>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppSchoolLesson>> create(Ref ref) {
    return schoolLessons(ref);
  }
}

String _$schoolLessonsHash() => r'1373f68c33f8581654301ea2066d9b5474c58d6c';

@ProviderFor(schoolTerms)
const schoolTermsProvider = SchoolTermsProvider._();

final class SchoolTermsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppSchoolTerm>>,
          List<AppSchoolTerm>,
          Stream<List<AppSchoolTerm>>
        >
    with
        $FutureModifier<List<AppSchoolTerm>>,
        $StreamProvider<List<AppSchoolTerm>> {
  const SchoolTermsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolTermsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolTermsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppSchoolTerm>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppSchoolTerm>> create(Ref ref) {
    return schoolTerms(ref);
  }
}

String _$schoolTermsHash() => r'25134b507a58eaa76dc9738f8fb90cdbb56e9dd9';

@ProviderFor(schoolClosures)
const schoolClosuresProvider = SchoolClosuresProvider._();

final class SchoolClosuresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppSchoolClosure>>,
          List<AppSchoolClosure>,
          Stream<List<AppSchoolClosure>>
        >
    with
        $FutureModifier<List<AppSchoolClosure>>,
        $StreamProvider<List<AppSchoolClosure>> {
  const SchoolClosuresProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolClosuresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolClosuresHash();

  @$internal
  @override
  $StreamProviderElement<List<AppSchoolClosure>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppSchoolClosure>> create(Ref ref) {
    return schoolClosures(ref);
  }
}

String _$schoolClosuresHash() => r'ccc73e340d640cdbc21edbd4285223a3ce099460';

@ProviderFor(schoolEvents)
const schoolEventsProvider = SchoolEventsProvider._();

final class SchoolEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppSchoolEvent>>,
          List<AppSchoolEvent>,
          Stream<List<AppSchoolEvent>>
        >
    with
        $FutureModifier<List<AppSchoolEvent>>,
        $StreamProvider<List<AppSchoolEvent>> {
  const SchoolEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppSchoolEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppSchoolEvent>> create(Ref ref) {
    return schoolEvents(ref);
  }
}

String _$schoolEventsHash() => r'd73e4a1e19fb71aa7906e5495acc4cff90ded030';

@ProviderFor(schoolDay)
const schoolDayProvider = SchoolDayFamily._();

final class SchoolDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchoolDaySnapshot>,
          SchoolDaySnapshot,
          FutureOr<SchoolDaySnapshot>
        >
    with
        $FutureModifier<SchoolDaySnapshot>,
        $FutureProvider<SchoolDaySnapshot> {
  const SchoolDayProvider._({
    required SchoolDayFamily super.from,
    required CivilDate super.argument,
  }) : super(
         retry: null,
         name: r'schoolDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$schoolDayHash();

  @override
  String toString() {
    return r'schoolDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SchoolDaySnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchoolDaySnapshot> create(Ref ref) {
    final argument = this.argument as CivilDate;
    return schoolDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$schoolDayHash() => r'9a968081eee0e5d71103ecb25e04f4926c82197b';

final class SchoolDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SchoolDaySnapshot>, CivilDate> {
  const SchoolDayFamily._()
    : super(
        retry: null,
        name: r'schoolDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SchoolDayProvider call(CivilDate date) =>
      SchoolDayProvider._(argument: date, from: this);

  @override
  String toString() => r'schoolDayProvider';
}
