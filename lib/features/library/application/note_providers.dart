import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/note_dao.dart';
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/note_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_providers.g.dart';

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  return NoteRepository(NoteDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppNote>> allNotes(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(noteRepositoryProvider).watchAll(userId);
}

@riverpod
Stream<AppNote?> noteById(Ref ref, String noteId) {
  return ref.watch(noteRepositoryProvider).watchById(noteId);
}
