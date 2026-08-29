import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/document_dao.dart';
import 'package:life_os/data/repositories/document_repository.dart';
import 'package:life_os/data/repositories/models/app_document.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_providers.g.dart';

@Riverpod(keepAlive: true)
DocumentRepository documentRepository(Ref ref) {
  return DocumentRepository(DocumentDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppDocument>> allDocuments(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(documentRepositoryProvider).watchAll(userId);
}
