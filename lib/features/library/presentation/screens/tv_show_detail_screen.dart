import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/features/library/presentation/widgets/mark_watched_sheet.dart';
import 'package:life_os/routing/routes.dart';

/// TV show detail — the show-level rating here is 1-5★, same scale as
/// films (Part 42: the show's own rating is independent of any episode's
/// 1-6★ rating, never averaged from them). Seasons are listed below so the
/// user can drill into per-episode tracking (`season_episodes_screen.dart`).
class TvShowDetailScreen extends ConsumerWidget {
  const TvShowDetailScreen({required this.showId, super.key});

  final String showId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final provider = libraryItemByIdProvider(showId);
    final asyncItem = ref.watch(provider);
    return asyncItem.when(
      loading: () => Scaffold(backgroundColor: colors.neutrals.bg, body: const Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        backgroundColor: colors.neutrals.bg,
        appBar: AppBar(),
        body: LErrorState(message: "Couldn't load this show.", onRetry: () => ref.invalidate(provider)),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: colors.neutrals.bg,
            appBar: AppBar(),
            body: const LEmptyState(
              icon: Icons.tv_outlined,
              title: 'Show not found',
              message: 'It may have been removed from your library.',
            ),
          );
        }
        return _TvShowDetailBody(item: item);
      },
    );
  }
}

class _TvShowDetailBody extends ConsumerWidget {
  const _TvShowDetailBody({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final repository = ref.read(libraryItemRepositoryProvider);
    final subtitleParts = [
      if (item.year != null) '${item.year}',
      if (item.genres.isNotEmpty) item.genres.join(', '),
    ];

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(item.isFavourite ? Icons.favorite : Icons.favorite_border),
            tooltip: item.isFavourite ? 'Remove favourite' : 'Add favourite',
            color: item.isFavourite ? colors.semantic('danger').base : null,
            onPressed: () => repository.setFavourite(item.id, isFavourite: !item.isFavourite),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LifeSpace.s16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LPosterTile(width: 120, imageProvider: posterImageFor(ref, MediaType.tv, item.posterPath)),
              const SizedBox(width: LifeSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitleParts.isNotEmpty)
                      Text(subtitleParts.join('  |  '), style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
                    if (item.creators.isNotEmpty) ...[
                      const SizedBox(height: LifeSpace.s4),
                      Text('Created by ${item.creators.join(', ')}', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
                    ],
                    const SizedBox(height: LifeSpace.s12),
                    Text('Show rating', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3)),
                    const SizedBox(height: LifeSpace.s4),
                    LStarRating(
                      rating: item.rating,
                      size: 24,
                      onChanged: (value) => repository.setRating(item.id, value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.overview != null && item.overview!.isNotEmpty) ...[
            const SizedBox(height: LifeSpace.s20),
            Text(item.overview!, style: context.textStyles.body.copyWith(color: colors.neutrals.ink)),
          ],
          const SizedBox(height: LifeSpace.s24),
          if (item.status == LibraryItemStatus.done)
            LButton(
              label: 'Edit watched details',
              variant: LButtonVariant.tonal,
              onPressed: () => MarkWatchedSheet.show(context, item),
            )
          else
            Row(
              children: [
                Expanded(
                  child: LButton(
                    label: item.status == LibraryItemStatus.inProgress ? 'Watching' : 'Start watching',
                    variant: item.status == LibraryItemStatus.inProgress ? LButtonVariant.tonal : LButtonVariant.filled,
                    onPressed: () => repository.setStatus(item.id, status: LibraryItemStatus.inProgress),
                  ),
                ),
                const SizedBox(width: LifeSpace.s12),
                Expanded(
                  child: LButton(
                    label: 'Mark Watched',
                    variant: LButtonVariant.tonal,
                    onPressed: () => MarkWatchedSheet.show(context, item),
                  ),
                ),
              ],
            ),
          const SizedBox(height: LifeSpace.s24),
          const LSectionHeader(title: 'Seasons'),
          const SizedBox(height: LifeSpace.s8),
          _SeasonList(item: item),
          const SizedBox(height: LifeSpace.s24),
          LButton(
            label: 'Add to Top list',
            variant: LButtonVariant.tonal,
            icon: Icons.emoji_events_outlined,
            onPressed: () async {
              final userId = await ref.read(currentUserIdProvider.future);
              final result = await ref.read(topListRepositoryProvider).add(userId, item.mediaType, item.id);
              if (!context.mounted) return;
              result.when(
                ok: (_) => LToast.show(context, 'Added to your Top list'),
                err: (f) => LToast.show(context, f.message),
              );
            },
          ),
          const SizedBox(height: LifeSpace.s24),
          LButton(
            label: 'Remove from library',
            variant: LButtonVariant.destructive,
            onPressed: () async {
              final confirmed = await LConfirmDialog.show(
                context,
                title: 'Remove ${item.title}?',
                message: 'This removes it from your library entirely.',
              );
              if (!confirmed) return;
              await repository.remove(item.id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
    );
  }
}

/// §16.7: no poster/data is "missing", not a crash — a manually-added show
/// (no `externalId`) or a TMDB outage both fall back to an honest message
/// instead of pretending season data exists.
class _SeasonList extends ConsumerWidget {
  const _SeasonList({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final externalId = item.externalId;
    if (externalId == null) {
      return Text(
        'Season data needs a TMDB match — this show was added manually.',
        style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
      );
    }

    final provider = tvShowMetadataProvider(externalId);
    final asyncDetail = ref.watch(provider);
    return asyncDetail.when(
      loading: () => const Padding(padding: EdgeInsets.all(LifeSpace.s16), child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => LErrorState(message: "Couldn't load season data.", onRetry: () => ref.invalidate(provider)),
      data: (result) {
        return result.when(
          ok: (detail) {
            final seasonCount = detail.seasonCount;
            if (seasonCount == null || seasonCount == 0) {
              return Text(
                "This show's seasons aren't listed by the provider yet.",
                style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
              );
            }
            return Column(
              children: [
                for (var season = 1; season <= seasonCount; season++)
                  LListTile(
                    title: 'Season $season',
                    trailing: Icon(Icons.chevron_right, color: colors.neutrals.ink3),
                    onTap: () => context.push(
                      Routes.libraryTvSeason.replaceFirst(':id', item.id).replaceFirst(':seasonNumber', '$season'),
                    ),
                  ),
              ],
            );
          },
          err: (failure) => LErrorState(message: failure.message, onRetry: () => ref.invalidate(provider)),
        );
      },
    );
  }
}
