// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_toggle.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A boolean setting backed by the key/value `Preferences` table, for the
/// many independent on/off switches Settings needs (Notifications'
/// categories, Privacy's opt-outs) without a schema change per switch.
/// Unset reads as `false` — every toggle here defaults off.

@ProviderFor(boolPreference)
const boolPreferenceProvider = BoolPreferenceFamily._();

/// A boolean setting backed by the key/value `Preferences` table, for the
/// many independent on/off switches Settings needs (Notifications'
/// categories, Privacy's opt-outs) without a schema change per switch.
/// Unset reads as `false` — every toggle here defaults off.

final class BoolPreferenceProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// A boolean setting backed by the key/value `Preferences` table, for the
  /// many independent on/off switches Settings needs (Notifications'
  /// categories, Privacy's opt-outs) without a schema change per switch.
  /// Unset reads as `false` — every toggle here defaults off.
  const BoolPreferenceProvider._({
    required BoolPreferenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'boolPreferenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boolPreferenceHash();

  @override
  String toString() {
    return r'boolPreferenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return boolPreference(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BoolPreferenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boolPreferenceHash() => r'112e36f2ed74ea10de533018af1ef4a3da3633f7';

/// A boolean setting backed by the key/value `Preferences` table, for the
/// many independent on/off switches Settings needs (Notifications'
/// categories, Privacy's opt-outs) without a schema change per switch.
/// Unset reads as `false` — every toggle here defaults off.

final class BoolPreferenceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  const BoolPreferenceFamily._()
    : super(
        retry: null,
        name: r'boolPreferenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A boolean setting backed by the key/value `Preferences` table, for the
  /// many independent on/off switches Settings needs (Notifications'
  /// categories, Privacy's opt-outs) without a schema change per switch.
  /// Unset reads as `false` — every toggle here defaults off.

  BoolPreferenceProvider call(String key) =>
      BoolPreferenceProvider._(argument: key, from: this);

  @override
  String toString() => r'boolPreferenceProvider';
}

@ProviderFor(stringPreference)
const stringPreferenceProvider = StringPreferenceFamily._();

final class StringPreferenceProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  const StringPreferenceProvider._({
    required StringPreferenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stringPreferenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stringPreferenceHash();

  @override
  String toString() {
    return r'stringPreferenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return stringPreference(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StringPreferenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stringPreferenceHash() => r'b665a34024edc8b2f011317eaa1107a3d3012132';

final class StringPreferenceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  const StringPreferenceFamily._()
    : super(
        retry: null,
        name: r'stringPreferenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StringPreferenceProvider call(String key) =>
      StringPreferenceProvider._(argument: key, from: this);

  @override
  String toString() => r'stringPreferenceProvider';
}
