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

/// Same "constructed straight from the DAO" reasoning as
/// `dataSettingsSearchRepository` above — Documents' own quota line in
/// §22.5's Data screen, per §17.3's "total quota shown in Settings → Data."

@ProviderFor(dataSettingsDocumentRepository)
const dataSettingsDocumentRepositoryProvider =
    DataSettingsDocumentRepositoryProvider._();

/// Same "constructed straight from the DAO" reasoning as
/// `dataSettingsSearchRepository` above — Documents' own quota line in
/// §22.5's Data screen, per §17.3's "total quota shown in Settings → Data."

final class DataSettingsDocumentRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentRepository,
          DocumentRepository,
          DocumentRepository
        >
    with $Provider<DocumentRepository> {
  /// Same "constructed straight from the DAO" reasoning as
  /// `dataSettingsSearchRepository` above — Documents' own quota line in
  /// §22.5's Data screen, per §17.3's "total quota shown in Settings → Data."
  const DataSettingsDocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataSettingsDocumentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataSettingsDocumentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepository create(Ref ref) {
    return dataSettingsDocumentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepository>(value),
    );
  }
}

String _$dataSettingsDocumentRepositoryHash() =>
    r'c25b321d2d471d10751408a82115551f7f861e3f';

@ProviderFor(documentStorageBytes)
const documentStorageBytesProvider = DocumentStorageBytesProvider._();

final class DocumentStorageBytesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const DocumentStorageBytesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentStorageBytesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentStorageBytesHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return documentStorageBytes(ref);
  }
}

String _$documentStorageBytesHash() =>
    r'27aa2730ba91ad6c479fda2e1b02d088f243d6d6';
