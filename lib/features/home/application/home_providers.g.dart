// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeSnapshot)
const homeSnapshotProvider = HomeSnapshotProvider._();

final class HomeSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeSnapshot>,
          HomeSnapshot,
          FutureOr<HomeSnapshot>
        >
    with $FutureModifier<HomeSnapshot>, $FutureProvider<HomeSnapshot> {
  const HomeSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSnapshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSnapshotHash();

  @$internal
  @override
  $FutureProviderElement<HomeSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HomeSnapshot> create(Ref ref) {
    return homeSnapshot(ref);
  }
}

String _$homeSnapshotHash() => r'06a3798c42bad6af7dcc30140ebf61a34c2a8d38';
