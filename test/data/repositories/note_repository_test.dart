import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/note_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/models/app_note.dart';
import 'package:life_os/data/repositories/models/note_block.dart';
import 'package:life_os/data/repositories/note_repository.dart';

AppNote _okNote(Result<AppNote, Failure> result) =>
    result.when(ok: (n) => n, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late NoteRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = NoteRepository(NoteDao(database));
  });

  tearDown(() => database.close());

  test('create then watchAll/watchById round-trips title, blocks, folder and colour', () async {
    final created = await repository.createNote(
      userId: 'u1',
      title: 'Groceries',
      blocks: const [NoteBlock(type: NoteBlockType.checklistItem, text: 'Milk'), NoteBlock(type: NoteBlockType.checklistItem, text: 'Eggs')],
      folderId: 'f1',
      colour: 'plans',
    );
    final note = _okNote(created);

    final all = await repository.watchAll('u1').first;
    expect(all, hasLength(1));
    expect(all.single.title, 'Groceries');
    expect(all.single.blocks.map((b) => b.text), ['Milk', 'Eggs']);

    final byId = await repository.watchById(note.id).first;
    expect(byId!.folderId, 'f1');
    expect(byId.colour, 'plans');
  });

  test('an empty note (no title, no blocks) round-trips cleanly', () async {
    final created = await repository.createNote(userId: 'u1');
    final note = _okNote(created);
    expect(note.title, isNull);
    expect(note.blocks, isEmpty);

    final byId = await repository.watchById(note.id).first;
    expect(byId!.title, isNull);
    expect(byId.blocks, isEmpty);
  });

  test('updateNote overwrites title and blocks, and plainText is derived, not stored separately', () async {
    final note = _okNote(await repository.createNote(userId: 'u1', title: 'Old'));
    await repository.updateNote(
      note.copyWith(title: 'New', blocks: const [NoteBlock(type: NoteBlockType.paragraph, text: 'Hello'), NoteBlock(type: NoteBlockType.divider)]),
    );

    final reloaded = await repository.watchById(note.id).first;
    expect(reloaded!.title, 'New');
    expect(reloaded.plainText, 'Hello'); // divider block has no text, excluded
  });

  test('setPinned toggles pinned and pinned notes sort first', () async {
    final a = _okNote(await repository.createNote(userId: 'u1', title: 'A'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final b = _okNote(await repository.createNote(userId: 'u1', title: 'B'));

    await repository.setPinned(a.id, pinned: true);
    final all = await repository.watchAll('u1').first;
    expect(all.first.id, a.id);
    expect(all.first.pinned, isTrue);
    expect(all.last.id, b.id);
  });

  test('deleteNote is a soft delete: it disappears from watchAll and watchById', () async {
    final note = _okNote(await repository.createNote(userId: 'u1', title: 'Temporary'));
    await repository.deleteNote(note.id);
    expect(await repository.watchAll('u1').first, isEmpty);
    expect(await repository.watchById(note.id).first, isNull);
  });

  test("watchAll only returns the given user's notes", () async {
    await repository.createNote(userId: 'u1', title: 'Mine');
    await repository.createNote(userId: 'u2', title: 'Not mine');
    final all = await repository.watchAll('u1').first;
    expect(all.map((n) => n.title), ['Mine']);
  });
}
