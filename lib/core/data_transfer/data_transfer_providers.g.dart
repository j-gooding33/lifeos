// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_transfer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dataExportService)
const dataExportServiceProvider = DataExportServiceProvider._();

final class DataExportServiceProvider
    extends
        $FunctionalProvider<
          DataExportService,
          DataExportService,
          DataExportService
        >
    with $Provider<DataExportService> {
  const DataExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataExportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataExportServiceHash();

  @$internal
  @override
  $ProviderElement<DataExportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DataExportService create(Ref ref) {
    return dataExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportService>(value),
    );
  }
}

String _$dataExportServiceHash() => r'04b4543cb5180c8fe0b8c995c4158e5a9784e6c3';

@ProviderFor(dataImportService)
const dataImportServiceProvider = DataImportServiceProvider._();

final class DataImportServiceProvider
    extends
        $FunctionalProvider<
          DataImportService,
          DataImportService,
          DataImportService
        >
    with $Provider<DataImportService> {
  const DataImportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataImportServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataImportServiceHash();

  @$internal
  @override
  $ProviderElement<DataImportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DataImportService create(Ref ref) {
    return dataImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataImportService>(value),
    );
  }
}

String _$dataImportServiceHash() => r'a177a387939ef8a2752ee708cf5cc48d996c0df9';
