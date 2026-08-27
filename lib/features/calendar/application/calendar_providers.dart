import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/event_dao.dart';
import 'package:life_os/data/repositories/event_repository.dart';
import 'package:life_os/data/repositories/models/app_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_providers.g.dart';

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) {
  return EventRepository(EventDao(ref.watch(appDatabaseProvider)));
}

/// §14.5: one range query per visible period.
@riverpod
Stream<List<AppEvent>> eventsInRange(
  Ref ref,
  CivilDate from,
  CivilDate through,
) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(eventRepositoryProvider).watchInRange(userId, from, through);
}

@riverpod
Stream<AppEvent?> eventById(Ref ref, String eventId) {
  return ref.watch(eventRepositoryProvider).watchById(eventId);
}
