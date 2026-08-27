import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/top_list_dao.dart';
import 'package:life_os/data/local/daos/tv_episode_dao.dart';
import 'package:life_os/data/media/media_metadata_provider.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/open_library_provider.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/top_list_repository.dart';
import 'package:life_os/data/repositories/tv_episode_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_providers.g.dart';

@Riverpod(keepAlive: true)
LibraryItemRepository libraryItemRepository(Ref ref) {
  return LibraryItemRepository(LibraryItemDao(ref.watch(appDatabaseProvider)));
}

@Riverpod(keepAlive: true)
TvEpisodeRepository tvEpisodeRepository(Ref ref) {
  return TvEpisodeRepository(TvEpisodeDao(ref.watch(appDatabaseProvider)));
}

@Riverpod(keepAlive: true)
TopListRepository topListRepository(Ref ref) {
  return TopListRepository(TopListDao(ref.watch(appDatabaseProvider)));
}

/// §16.2: films and TV both use TMDB; books use Open Library. One provider
/// instance each, kept alive for the app's lifetime.
@Riverpod(keepAlive: true)
TmdbMetadataProvider tmdbMetadataProvider(Ref ref) => TmdbMetadataProvider();

@Riverpod(keepAlive: true)
OpenLibraryProvider openLibraryProvider(Ref ref) => OpenLibraryProvider();

MediaMetadataProvider mediaProviderFor(WidgetRef ref, MediaType type) {
  return type == MediaType.book ? ref.watch(openLibraryProviderProvider) : ref.watch(tmdbMetadataProviderProvider);
}

@riverpod
Stream<List<AppLibraryItem>> libraryByStatus(Ref ref, MediaType type, LibraryItemStatus status) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(libraryItemRepositoryProvider).watchByStatus(userId, type, status);
}

@riverpod
Stream<List<AppLibraryItem>> libraryAll(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(libraryItemRepositoryProvider).watchAll(userId, type);
}

@riverpod
Stream<List<AppLibraryItem>> libraryFavourites(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(libraryItemRepositoryProvider).watchFavourites(userId, type);
}

@riverpod
Stream<List<AppLibraryItem>> libraryRated(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(libraryItemRepositoryProvider).watchRated(userId, type);
}

@riverpod
Stream<AppLibraryItem?> libraryItemById(Ref ref, String id) {
  return ref.watch(libraryItemRepositoryProvider).watchById(id);
}

@riverpod
Stream<List<AppTvEpisode>> episodesForShow(Ref ref, String libraryItemId) {
  return ref.watch(tvEpisodeRepositoryProvider).watchForShow(libraryItemId);
}

@riverpod
Stream<List<AppTvEpisode>> episodesForSeason(Ref ref, String libraryItemId, int seasonNumber) {
  return ref.watch(tvEpisodeRepositoryProvider).watchForSeason(libraryItemId, seasonNumber);
}

@riverpod
Stream<List<AppTvEpisode>> ratedEpisodes(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(tvEpisodeRepositoryProvider).watchRated(userId);
}

@riverpod
Stream<List<TopListEntry>> topList(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(topListRepositoryProvider).watch(userId, type);
}
