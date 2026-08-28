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
import 'package:life_os/design/components/l_notes_section.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/features/library/presentation/widgets/mark_watched_sheet.dart';
import 'package:life_os/features/library/presentation/widgets/schedule_this_sheet.dart';

/// M8 Part 4: film detail — status, rating (interactive, independent of
/// watched state per §43), the watched log, and the Top-list/remove
/// actions.
class FilmDetailScreen extends ConsumerWidget {
  const FilmDetailScreen({required this.filmId, super.key});

  final String filmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final provider = libraryItemByIdProvider(filmId);
    final asyncItem = ref.watch(provider);
    return asyncItem.when(
      loading: () => Scaffold(backgroundColor: colors.neutrals.bg, body: const Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        backgroundColor: colors.neutrals.bg,
        appBar: AppBar(),
        body: LErrorState(message: "Couldn't load this film.", onRetry: () => ref.invalidate(provider)),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: colors.neutrals.bg,
            appBar: AppBar(),
            body: const LEmptyState(
              icon: Icons.movie_outlined,
              title: 'Film not found',
              message: 'It may have been removed from your library.',
            ),
          );
        }
        return _FilmDetailBody(item: item);
      },
    );
  }
}

class _FilmDetailBody extends ConsumerWidget {
  const _FilmDetailBody({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final repository = ref.read(libraryItemRepositoryProvider);
    final subtitleParts = [
      if (item.year != null) '${item.year}',
      if (item.runtimeMinutes != null) '${item.runtimeMinutes} min',
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
              LPosterTile(width: 120, imageProvider: posterImageFor(ref, MediaType.film, item.posterPath)),
              const SizedBox(width: LifeSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitleParts.isNotEmpty)
                      Text(subtitleParts.join('  |  '), style: context.textStyles.subhead.copyWith(color: colors.neutrals.ink2)),
                    if (item.creators.isNotEmpty) ...[
                      const SizedBox(height: LifeSpace.s4),
                      Text('Directed by ${item.creators.join(', ')}', style: context.textStyles.caption.copyWith(color: colors.neutrals.ink2)),
                    ],
                    const SizedBox(height: LifeSpace.s12),
                    LStarRating(
                      rating: item.rating,
                      size: 28,
                      onChanged: (value) => repository.setRating(item.id, value),
                    ),
                    if (item.isRated)
                      GestureDetector(
                        onTap: () => repository.setRating(item.id, null),
                        child: Padding(
                          padding: const EdgeInsets.only(top: LifeSpace.s4),
                          child: Text('Clear rating', style: context.textStyles.caption.copyWith(color: colors.accent.base)),
                        ),
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
          if (item.status == LibraryItemStatus.done) ...[
            Text(
              item.finishedAt == null
                  ? 'Watched'
                  : 'Watched on ${item.finishedAt!.year}-${item.finishedAt!.month.toString().padLeft(2, '0')}-${item.finishedAt!.day.toString().padLeft(2, '0')}',
              style: context.textStyles.bodyStrong.copyWith(color: colors.neutrals.ink),
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: LifeSpace.s8),
              Text(item.notes!, style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
            ],
            const SizedBox(height: LifeSpace.s12),
            Row(
              children: [
                Expanded(
                  child: LButton(
                    label: 'Edit watched details',
                    variant: LButtonVariant.tonal,
                    onPressed: () => MarkWatchedSheet.show(context, item),
                  ),
                ),
                const SizedBox(width: LifeSpace.s12),
                Expanded(
                  child: LButton(
                    label: 'Move to watchlist',
                    variant: LButtonVariant.plain,
                    onPressed: () => repository.setStatus(item.id, status: LibraryItemStatus.wishlist),
                  ),
                ),
              ],
            ),
          ] else
            LButton(label: 'Mark Watched', onPressed: () => MarkWatchedSheet.show(context, item)),
          const SizedBox(height: LifeSpace.s12),
          LButton(
            label: 'Schedule this',
            variant: LButtonVariant.tonal,
            icon: Icons.event_repeat_outlined,
            onPressed: () => ScheduleThisSheet.show(context, item),
          ),
          const SizedBox(height: LifeSpace.s12),
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
          LNotesSection(entityType: 'film', entityId: item.id),
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
