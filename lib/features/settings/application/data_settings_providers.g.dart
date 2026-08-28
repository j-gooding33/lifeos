// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Constructed straight from the DAO rather than importing the Search
/// feature's own provider (CLAUDE.md rule 4: features don't import
/// features) — same pattern as `resolveDomainColour`/`LNotesSection`.

@ProviderFor(dataSettingsSearchRepository)
const dataSettingsSearchRepositoryProvider =
    DataSettingsSearchRepositoryProvider._();

/// Constructed straight from the DAO rather than importing the Search
/// feature's own provider (CLAUDE.md rule 4: features don't import
/// features) — same pattern as `resolveDomainColour`/`LNotesSection`.

final class DataSettingsSearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  /// Constructed straight from the DAO rather than importing the Search
  /// feature's own provider (CLAUDE.md rule 4: features don't import
  /// features) — same pattern as `resolveDomainColour`/`LNotesSection`.
  const DataSettingsSearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataSettingsSearchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataSettingsSearchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return dataSettingsSearchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$dataSettingsSearchRepositoryHash() =>
    r'dd96c71e21facfcefa972d06860fffc94ee3b4b5';

/// §22.5's "storage used" — the local SQLite file's size on disk. Same
/// path `AppDatabase`'s own `_openConnection` uses.

@ProviderFor(databaseSizeBytes)
const databaseSizeBytesProvider = DatabaseSizeBytesProvider._();

/// §22.5's "storage used" — the local SQLite file's size on disk. Same
/// path `AppDatabase`'s own `_openConnection` uses.

final class DatabaseSizeBytesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// §22.5's "storage used" — the local SQLite file's size on disk. Same
  /// path `AppDatabase`'s own `_openConnection` uses.
  const DatabaseSizeBytesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseSizeBytesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseSizeBytesHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return databaseSizeBytes(ref);
  }
}

String _$databaseSizeBytesHash() => r'bda0c450403375ef3455034695f46121e42367f7';
