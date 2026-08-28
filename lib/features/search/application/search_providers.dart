import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/search_dao.dart';
import 'package:life_os/data/repositories/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_providers.g.dart';

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(SearchDao(ref.watch(appDatabaseProvider)));
}
