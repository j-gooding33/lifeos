// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiPermissionsRepository)
const aiPermissionsRepositoryProvider = AiPermissionsRepositoryProvider._();

final class AiPermissionsRepositoryProvider
    extends
        $FunctionalProvider<
          AiPermissionsRepository,
          AiPermissionsRepository,
          AiPermissionsRepository
        >
    with $Provider<AiPermissionsRepository> {
  const AiPermissionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiPermissionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiPermissionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiPermissionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiPermissionsRepository create(Ref ref) {
    return aiPermissionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiPermissionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiPermissionsRepository>(value),
    );
  }
}

String _$aiPermissionsRepositoryHash() =>
    r'f4a7ce8fa0bbe04b7c85033628ff03a1c3359193';

@ProviderFor(aiPermissionScopes)
const aiPermissionScopesProvider = AiPermissionScopesProvider._();

final class AiPermissionScopesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiPermissionScopes>,
          AiPermissionScopes,
          Stream<AiPermissionScopes>
        >
    with
        $FutureModifier<AiPermissionScopes>,
        $StreamProvider<AiPermissionScopes> {
  const AiPermissionScopesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiPermissionScopesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiPermissionScopesHash();

  @$internal
  @override
  $StreamProviderElement<AiPermissionScopes> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AiPermissionScopes> create(Ref ref) {
    return aiPermissionScopes(ref);
  }
}

String _$aiPermissionScopesHash() =>
    r'7ec2384601594c5f97c15a1fe89825f82c86f990';
