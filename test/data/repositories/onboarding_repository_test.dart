import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/data/repositories/onboarding_repository.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

void main() {
  late AppDatabase database;
  late OnboardingRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = OnboardingRepository(PreferencesRepository(PreferencesDao(database)));
  });

  tearDown(() => database.close());

  test('hasOnboarded defaults to false for a user who has never set it', () async {
    expect(await repository.watchHasOnboarded('u1').first, isFalse);
  });

  test('setHasOnboarded persists and is reflected on the watch stream', () async {
    await repository.setHasOnboarded('u1', value: true);
    expect(await repository.watchHasOnboarded('u1').first, isTrue);
  });

  test('answers round-trip through save/get, including media type', () async {
    const answers = [
      OnboardingAnswer(question: OnboardingQuestion.startDoing, text: 'Drink more water'),
      OnboardingAnswer(question: OnboardingQuestion.readWatch, text: 'Dune', mediaType: MediaType.book),
    ];
    await repository.saveAnswers('u1', answers);

    final loaded = await repository.getAnswers('u1');
    expect(loaded, hasLength(2));
    expect(loaded[0].question, OnboardingQuestion.startDoing);
    expect(loaded[0].mediaType, isNull);
    expect(loaded[1].mediaType, MediaType.book);
  });

  test('getAnswers returns an empty list when nothing has been saved', () async {
    expect(await repository.getAnswers('u1'), isEmpty);
  });
}
