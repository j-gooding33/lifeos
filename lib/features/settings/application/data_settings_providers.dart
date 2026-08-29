import 'dart:io';

import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/document_dao.dart';
import 'package:life_os/data/local/daos/search_dao.dart';
import 'package:life_os/data/repositories/document_repository.dart';
import 'package:life_os/data/repositories/search_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_settings_providers.g.dart';

/// Constructed straight from the DAO rather than importing the Search
/// feature's own provider (CLAUDE.md rule 4: features don't import
/// features) — same pattern as `resolveDomainColour`/`LNotesSection`.
@Riverpod(keepAlive: true)
SearchRepository dataSettingsSearchRepository(Ref ref) {
  return SearchRepository(SearchDao(ref.watch(appDatabaseProvider)));
}

/// §22.5's "storage used" — the local SQLite file's size on disk. Same
/// path `AppDatabase`'s own `_openConnection` uses.
@riverpod
Future<int> databaseSizeBytes(Ref ref) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, 'life_os.sqlite'));
  if (!file.existsSync()) return 0;
  return file.length();
}

/// Same "constructed straight from the DAO" reasoning as
/// `dataSettingsSearchRepository` above — Documents' own quota line in
/// §22.5's Data screen, per §17.3's "total quota shown in Settings → Data."
@Riverpod(keepAlive: true)
DocumentRepository dataSettingsDocumentRepository(Ref ref) {
  return DocumentRepository(DocumentDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Future<int> documentStorageBytes(Ref ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return ref.watch(dataSettingsDocumentRepositoryProvider).totalSizeBytes(userId);
}
