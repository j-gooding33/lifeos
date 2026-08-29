// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentRepository)
const documentRepositoryProvider = DocumentRepositoryProvider._();

final class DocumentRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentRepository,
          DocumentRepository,
          DocumentRepository
        >
    with $Provider<DocumentRepository> {
  const DocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepository create(Ref ref) {
    return documentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepository>(value),
    );
  }
}

String _$documentRepositoryHash() =>
    r'd01d691d1003540f70aed9758a214f01878161a8';

@ProviderFor(allDocuments)
const allDocumentsProvider = AllDocumentsProvider._();

final class AllDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppDocument>>,
          List<AppDocument>,
          Stream<List<AppDocument>>
        >
    with
        $FutureModifier<List<AppDocument>>,
        $StreamProvider<List<AppDocument>> {
  const AllDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppDocument>> create(Ref ref) {
    return allDocuments(ref);
  }
}

String _$allDocumentsHash() => r'bab93bd50aa9afb3f0294d392bb2c98f3bff5669';
