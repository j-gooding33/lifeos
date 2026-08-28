import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/link_dao.dart';
import 'package:life_os/data/repositories/link_repository.dart';
import 'package:life_os/data/repositories/models/app_link.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_providers.g.dart';

@Riverpod(keepAlive: true)
LinkRepository linkRepository(Ref ref) {
  return LinkRepository(LinkDao(ref.watch(appDatabaseProvider)));
}

@riverpod
Stream<List<AppLink>> allLinks(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(linkRepositoryProvider).watchAll(userId);
}
