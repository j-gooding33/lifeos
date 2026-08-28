import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/journal_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/journal_repository.dart';
import 'package:life_os/data/repositories/models/app_journal_entry.dart';
import 'package:life_os/data/repositories/models/note_block.dart';

AppJournalEntry _okEntry(Result<AppJournalEntry, Failure> result) =>
    result.when(ok: (e) => e, err: (f) => throw StateError('expected Ok, got ${f.message}'));

void main() {
  late AppDatabase database;
  late JournalRepository repository;
  const today = CivilDate(2026, 8, 28);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = JournalRepository(JournalDao(database));
  });

  tearDown(() => database.close());

  test('getOrCreate makes a new empty entry the first time, for exactly that date', () async {
    final entry = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    expect(entry.date, today);
    expect(entry.blocks, isEmpty);
    expect(entry.mood, isNull);
  });

  test('getOrCreate returns the same row (same id) on a second call for the same day', () async {
    final first = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    final second = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    expect(second.id, first.id);

    final all = await repository.watchRecent('u1').first;
    expect(all, hasLength(1));
  });

  test('different days get different entries', () async {
    final day1 = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    final day2 = _okEntry(await repository.getOrCreate(userId: 'u1', date: today.addDays(1)));
    expect(day1.id, isNot(day2.id));

    final all = await repository.watchRecent('u1').first;
    expect(all, hasLength(2));
  });

  test('updateEntry round-trips blocks, plainText and mood', () async {
    final entry = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    await repository.updateEntry(
      entry.copyWith(blocks: const [NoteBlock(type: NoteBlockType.paragraph, text: 'A good day'), NoteBlock(type: NoteBlockType.divider)], mood: 4),
    );

    final reloaded = await repository.watchByDate('u1', today).first;
    expect(reloaded!.plainText, 'A good day');
    expect(reloaded.mood, 4);
  });

  test('clearMood removes a previously-set mood', () async {
    final entry = _okEntry(await repository.getOrCreate(userId: 'u1', date: today));
    await repository.updateEntry(entry.copyWith(mood: 2));
    final withMood = await repository.watchByDate('u1', today).first;
    await repository.updateEntry(withMood!.copyWith(clearMood: true));

    final cleared = await repository.watchByDate('u1', today).first;
    expect(cleared!.mood, isNull);
  });

  test("watchRecent only returns the given user's entries, newest date first", () async {
    await repository.getOrCreate(userId: 'u1', date: today);
    await repository.getOrCreate(userId: 'u1', date: today.addDays(-1));
    await repository.getOrCreate(userId: 'u2', date: today);

    final recent = await repository.watchRecent('u1').first;
    expect(recent.map((e) => e.date), [today, today.addDays(-1)]);
  });
}
