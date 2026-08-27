import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/activity_log_dao.dart';
import 'package:life_os/data/local/daos/collection_dao.dart';
import 'package:life_os/data/local/daos/library_item_dao.dart';
import 'package:life_os/data/local/daos/plan_dao.dart';
import 'package:life_os/data/local/daos/top_list_dao.dart';
import 'package:life_os/data/local/daos/tv_episode_dao.dart';
import 'package:life_os/data/media/media_metadata_provider.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/media/open_library_provider.dart';
import 'package:life_os/data/media/tmdb_metadata_provider.dart';
import 'package:life_os/data/repositories/collection_repository.dart';
import 'package:life_os/data/repositories/library_item_repository.dart';
import 'package:life_os/data/repositories/models/app_collection.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/data/repositories/models/app_plan.dart';
import 'package:life_os/data/repositories/plan_repository.dart';
import 'package:life_os/data/repositories/top_list_repository.dart';
import 'package:life_os/data/repositories/tv_episode_repository.dart';
import 'package:life_os/features/library/application/library_stats.dart';
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

@Riverpod(keepAlive: true)
CollectionRepository collectionRepository(Ref ref) {
  return CollectionRepository(CollectionDao(ref.watch(appDatabaseProvider)));
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

@riverpod
Stream<List<AppCollection>> collections(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(collectionRepositoryProvider).watchAll(userId);
}

@riverpod
Stream<AppCollection?> collectionById(Ref ref, String id) {
  return ref.watch(collectionRepositoryProvider).watchById(id);
}

/// Joins a collection's membership list to full items in one query — a
/// collection can hold a mix of films, TV shows and books.
@riverpod
Stream<List<AppLibraryItem>> collectionItems(Ref ref, String collectionId) {
  final itemRepository = ref.watch(libraryItemRepositoryProvider);
  return ref.watch(collectionRepositoryProvider).watchItemIds(collectionId).asyncExpand(itemRepository.watchByIds);
}

@riverpod
Stream<Set<String>> collectionIdsContaining(Ref ref, String libraryItemId) {
  return ref.watch(collectionRepositoryProvider).watchCollectionIdsContaining(libraryItemId);
}

/// §16.4/§16.5's "Schedule this". `library/` needs `PlanRepository` for it,
/// but never `lib/features/plans/`'s own provider — that would be a
/// features-to-features import (rule 4). This wraps the same
/// `PlanDao`/database `plans/` own provider does, so a write through
/// either instance is visible to both.
@Riverpod(keepAlive: true)
PlanRepository libraryPlanRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return PlanRepository(PlanDao(database), ActivityLogDao(database));
}

@riverpod
Stream<List<AppPlan>> plansForMediaType(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref
      .watch(libraryPlanRepositoryProvider)
      .watchActive(userId)
      .map((plans) => plans.where((p) => p.mediaType == type.name).toList());
}

/// §16.6. Runtime is only a meaningful stat for films/TV — books don't
/// reliably track a runtime-equivalent (page counts aren't tracked at all
/// yet), so `includeRuntime` is false there rather than showing a fake `0`.
@riverpod
Stream<LibraryStats> libraryStats(Ref ref, MediaType type) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref
      .watch(libraryItemRepositoryProvider)
      .watchAll(userId, type)
      .map((items) => computeLibraryStats(items, now: DateTime.now(), includeRuntime: type != MediaType.book));
}

/// TMDB's search results don't include season count — only `detail()` does
/// — so the TV show detail screen needs one extra round trip the first
/// time it's opened to know how many season rows to offer.
@riverpod
Future<Result<MediaDetail, Failure>> tvShowMetadata(Ref ref, String externalId) {
  return ref.watch(tmdbMetadataProviderProvider).detail(externalId, MediaType.tv);
}

/// Fetches a season's episode list from the provider and imports it
/// (`TvEpisodeRepository.importSeason` never overwrites existing
/// watched/rating/log state) the first time that season's screen opens.
/// Silently a no-op — not an error — for a manually-added show or an
/// unconfigured provider, matching §16.7's "missing data, not a crash".
@riverpod
Future<Result<void, Failure>> seasonImport(Ref ref, String libraryItemId, int seasonNumber) async {
  final item = await ref.watch(libraryItemByIdProvider(libraryItemId).future);
  if (item == null || item.externalId == null) return const Ok(null);

  final tmdb = ref.watch(tmdbMetadataProviderProvider);
  if (!tmdb.isConfigured) return const Ok(null);

  final episodesResult = await tmdb.seasonEpisodes(item.externalId!, seasonNumber);
  if (episodesResult case Err(:final failure)) return Err(failure);
  final episodes = (episodesResult as Ok<List<EpisodeSummary>, Failure>).value;

  final userId = await ref.watch(currentUserIdProvider.future);
  return ref
      .watch(tvEpisodeRepositoryProvider)
      .importSeason(userId: userId, libraryItemId: libraryItemId, episodes: episodes);
}
