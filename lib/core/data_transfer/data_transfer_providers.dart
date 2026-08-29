import 'package:life_os/core/data_transfer/data_export_service.dart';
import 'package:life_os/core/data_transfer/data_import_service.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_transfer_providers.g.dart';

@Riverpod(keepAlive: true)
DataExportService dataExportService(Ref ref) {
  return DataExportService(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
DataImportService dataImportService(Ref ref) {
  return DataImportService(ref.watch(appDatabaseProvider));
}
