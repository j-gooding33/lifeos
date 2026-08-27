// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentThemeScheme)
const currentThemeSchemeProvider = CurrentThemeSchemeProvider._();

final class CurrentThemeSchemeProvider
    extends
        $FunctionalProvider<
          AsyncValue<LifeThemeScheme>,
          LifeThemeScheme,
          Stream<LifeThemeScheme>
        >
    with $FutureModifier<LifeThemeScheme>, $StreamProvider<LifeThemeScheme> {
  const CurrentThemeSchemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentThemeSchemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentThemeSchemeHash();

  @$internal
  @override
  $StreamProviderElement<LifeThemeScheme> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<LifeThemeScheme> create(Ref ref) {
    return currentThemeScheme(ref);
  }
}

String _$currentThemeSchemeHash() =>
    r'18498255c7b12832c7752ea032d9e9a3ff0936a2';
