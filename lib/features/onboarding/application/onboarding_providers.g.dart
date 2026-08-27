// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds its own repository instances straight from their DAOs (all under
/// `data/`, never another feature's `application/` folder) rather than
/// importing Tasks/Plans/Library's own provider files — CLAUDE.md rule 4,
/// "features do not import features". They wrap the same `AppDatabase`
/// singleton those features' own repositories do, so this is a second
/// stateless handle onto the same data, not a second source of truth.

@ProviderFor(projectRepository)
const projectRepositoryProvider = ProjectRepositoryProvider._();

/// Builds its own repository instances straight from their DAOs (all under
/// `data/`, never another feature's `application/` folder) rather than
/// importing Tasks/Plans/Library's own provider files — CLAUDE.md rule 4,
/// "features do not import features". They wrap the same `AppDatabase`
/// singleton those features' own repositories do, so this is a second
/// stateless handle onto the same data, not a second source of truth.

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectRepository,
          ProjectRepository,
          ProjectRepository
        >
    with $Provider<ProjectRepository> {
  /// Builds its own repository instances straight from their DAOs (all under
  /// `data/`, never another feature's `application/` folder) rather than
  /// importing Tasks/Plans/Library's own provider files — CLAUDE.md rule 4,
  /// "features do not import features". They wrap the same `AppDatabase`
  /// singleton those features' own repositories do, so this is a second
  /// stateless handle onto the same data, not a second source of truth.
  const ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'd7a83341b82133dd495ad166cf1ef27e7f25df81';

@ProviderFor(onboardingRepository)
const onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingRepository,
          OnboardingRepository,
          OnboardingRepository
        >
    with $Provider<OnboardingRepository> {
  const OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'7db090037f17bf6d90826aad1b69d1df8a15e1e7';

@ProviderFor(onboardingMapper)
const onboardingMapperProvider = OnboardingMapperProvider._();

final class OnboardingMapperProvider
    extends
        $FunctionalProvider<
          OnboardingMapper,
          OnboardingMapper,
          OnboardingMapper
        >
    with $Provider<OnboardingMapper> {
  const OnboardingMapperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingMapperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingMapperHash();

  @$internal
  @override
  $ProviderElement<OnboardingMapper> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnboardingMapper create(Ref ref) {
    return onboardingMapper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingMapper value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingMapper>(value),
    );
  }
}

String _$onboardingMapperHash() => r'5e748fcc45b7afcb05c6c6208f53989f6ee2af2f';

@ProviderFor(hasOnboarded)
const hasOnboardedProvider = HasOnboardedProvider._();

final class HasOnboardedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  const HasOnboardedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasOnboardedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasOnboardedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return hasOnboarded(ref);
  }
}

String _$hasOnboardedHash() => r'294cfeba0d727ef1377877c15ad008d947c8701b';
