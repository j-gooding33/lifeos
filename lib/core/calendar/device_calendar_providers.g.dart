// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceCalendarService)
const deviceCalendarServiceProvider = DeviceCalendarServiceProvider._();

final class DeviceCalendarServiceProvider
    extends
        $FunctionalProvider<
          DeviceCalendarService,
          DeviceCalendarService,
          DeviceCalendarService
        >
    with $Provider<DeviceCalendarService> {
  const DeviceCalendarServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCalendarServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarServiceHash();

  @$internal
  @override
  $ProviderElement<DeviceCalendarService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceCalendarService create(Ref ref) {
    return deviceCalendarService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceCalendarService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceCalendarService>(value),
    );
  }
}

String _$deviceCalendarServiceHash() =>
    r'51afcb4c81c65b2fef1013facb231bb23a5c49e6';

/// A fresh OS-level check each time something watches it (deliberately
/// not `keepAlive`) — permission can change from outside the app (Android
/// Settings), so the Calendar screen's banner should never trust a stale
/// cached answer from the last time it was open.

@ProviderFor(deviceCalendarPermissionGranted)
const deviceCalendarPermissionGrantedProvider =
    DeviceCalendarPermissionGrantedProvider._();

/// A fresh OS-level check each time something watches it (deliberately
/// not `keepAlive`) — permission can change from outside the app (Android
/// Settings), so the Calendar screen's banner should never trust a stale
/// cached answer from the last time it was open.

final class DeviceCalendarPermissionGrantedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// A fresh OS-level check each time something watches it (deliberately
  /// not `keepAlive`) — permission can change from outside the app (Android
  /// Settings), so the Calendar screen's banner should never trust a stale
  /// cached answer from the last time it was open.
  const DeviceCalendarPermissionGrantedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCalendarPermissionGrantedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarPermissionGrantedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return deviceCalendarPermissionGranted(ref);
  }
}

String _$deviceCalendarPermissionGrantedHash() =>
    r'd3e68d006f484cb7ee698f9de73f53dd9e7e2770';

@ProviderFor(deviceCalendars)
const deviceCalendarsProvider = DeviceCalendarsProvider._();

final class DeviceCalendarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceCalendarInfo>>,
          List<DeviceCalendarInfo>,
          FutureOr<List<DeviceCalendarInfo>>
        >
    with
        $FutureModifier<List<DeviceCalendarInfo>>,
        $FutureProvider<List<DeviceCalendarInfo>> {
  const DeviceCalendarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCalendarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarsHash();

  @$internal
  @override
  $FutureProviderElement<List<DeviceCalendarInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceCalendarInfo>> create(Ref ref) {
    return deviceCalendars(ref);
  }
}

String _$deviceCalendarsHash() => r'afa83cdcfb1e05f579e5e352894267d5260f0a97';

@ProviderFor(deviceCalendarEnabled)
const deviceCalendarEnabledProvider = DeviceCalendarEnabledFamily._();

final class DeviceCalendarEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const DeviceCalendarEnabledProvider._({
    required DeviceCalendarEnabledFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deviceCalendarEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceCalendarEnabledHash();

  @override
  String toString() {
    return r'deviceCalendarEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return deviceCalendarEnabled(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceCalendarEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceCalendarEnabledHash() =>
    r'39604460cdbe138931667b1297b473c88b728a54';

final class DeviceCalendarEnabledFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const DeviceCalendarEnabledFamily._()
    : super(
        retry: null,
        name: r'deviceCalendarEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeviceCalendarEnabledProvider call(String calendarId) =>
      DeviceCalendarEnabledProvider._(argument: calendarId, from: this);

  @override
  String toString() => r'deviceCalendarEnabledProvider';
}
