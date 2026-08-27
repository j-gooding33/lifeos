import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/core/school/school_week_engine.dart';
import 'package:life_os/data/local/daos/school_dao.dart';
import 'package:life_os/data/repositories/models/app_school.dart';
import 'package:life_os/data/repositories/school_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'school_providers.g.dart';

@Riverpod(keepAlive: true)
SchoolRepository schoolRepository(Ref ref) {
  return SchoolRepository(SchoolDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<AppSchoolProfile?> schoolProfile(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(schoolRepositoryProvider).watchProfile(userId);
}

@riverpod
Stream<List<AppSchoolLesson>> schoolLessons(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(schoolRepositoryProvider).watchLessons(userId);
}

@riverpod
Stream<List<AppSchoolTerm>> schoolTerms(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(schoolRepositoryProvider).watchTerms(userId);
}

@riverpod
Stream<List<AppSchoolClosure>> schoolClosures(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(schoolRepositoryProvider).watchClosures(userId);
}

@riverpod
Stream<List<AppSchoolEvent>> schoolEvents(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(schoolRepositoryProvider).watchEvents(userId);
}

/// Everything the School Dashboard needs for one date, composed from the
/// four underlying streams — kept as one snapshot so the dashboard doesn't
/// juggle four separate `AsyncValue`s itself.
class SchoolDaySnapshot {
  const SchoolDaySnapshot({
    required this.isOpen,
    required this.weekLabel,
    required this.lessons,
    required this.hasProfile,
  });

  final bool isOpen;
  final WeekLabel? weekLabel;
  final List<SchoolLessonSlot> lessons;

  /// False before the user has done School setup at all — the dashboard
  /// shows a setup prompt rather than an honest-but-confusing "closed"
  /// state in that case.
  final bool hasProfile;
}

@riverpod
Future<SchoolDaySnapshot> schoolDay(Ref ref, CivilDate date) async {
  final profile = await ref.watch(schoolProfileProvider.future);
  if (profile == null) {
    return const SchoolDaySnapshot(isOpen: false, weekLabel: null, lessons: [], hasProfile: false);
  }
  final terms = await ref.watch(schoolTermsProvider.future);
  final closures = await ref.watch(schoolClosuresProvider.future);
  final lessons = await ref.watch(schoolLessonsProvider.future);
  final repository = ref.watch(schoolRepositoryProvider);

  final isOpen = repository.isOpenOn(date: date, terms: terms, closures: closures);
  final weekLabel = repository.weekLabelOn(date, profile);
  final todaysLessons = isOpen ? repository.lessonsFor(date: date, profile: profile, lessons: lessons) : const <SchoolLessonSlot>[];

  return SchoolDaySnapshot(isOpen: isOpen, weekLabel: weekLabel, lessons: todaysLessons, hasProfile: true);
}
