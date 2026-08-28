// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentProfile)
const currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppProfile?>,
          AppProfile?,
          Stream<AppProfile?>
        >
    with $FutureModifier<AppProfile?>, $StreamProvider<AppProfile?> {
  const CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $StreamProviderElement<AppProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppProfile?> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'227c7f840c35ed2fd242842dff424dd909ea0fdb';
