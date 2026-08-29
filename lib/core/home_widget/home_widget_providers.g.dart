// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeWidgetService)
const homeWidgetServiceProvider = HomeWidgetServiceProvider._();

final class HomeWidgetServiceProvider
    extends
        $FunctionalProvider<
          HomeWidgetService,
          HomeWidgetService,
          HomeWidgetService
        >
    with $Provider<HomeWidgetService> {
  const HomeWidgetServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeWidgetServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeWidgetServiceHash();

  @$internal
  @override
  $ProviderElement<HomeWidgetService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeWidgetService create(Ref ref) {
    return homeWidgetService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeWidgetService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeWidgetService>(value),
    );
  }
}

String _$homeWidgetServiceHash() => r'51163dc0e278bfbeab31860a034ded61c1a3fdb4';
