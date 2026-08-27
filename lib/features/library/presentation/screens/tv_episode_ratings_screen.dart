import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/routing/routes.dart';

/// Episode-level ratings (1-6★) across every show — separate from
/// `tv_ratings_screen.dart`'s 1-5★ show ratings, since the scales aren't
/// comparable (Part 42). Sorted highest-first so a 6★ "personal favourite"
/// episode surfaces at the top.
class TvEpisodeRatingsScreen extends ConsumerWidget {
  const TvEpisodeRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncEpisodes = ref.watch(ratedEpisodesProvider);
    final asyncShows = ref.watch(libraryAllProvider(MediaType.tv));

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Episode ratings')),
      body: asyncEpisodes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            LErrorState(message: "Couldn't load episode ratings.", onRetry: () => ref.invalidate(ratedEpisodesProvider)),
        data: (episodes) {
          return asyncShows.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => LErrorState(
              message: "Couldn't load your shows.",
              onRetry: () => ref.invalidate(libraryAllProvider(MediaType.tv)),
            ),
            data: (shows) {
              if (episodes.isEmpty) {
                return const LEmptyState(
                  icon: Icons.star_border,
                  title: 'No rated episodes yet',
                  message: 'Rate an episode from its season page to see it here.',
                );
              }
              final showsById = {for (final s in shows) s.id: s};
              final sorted = [...episodes]..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
                itemBuilder: (context, index) {
                  final episode = sorted[index];
                  final show = showsById[episode.libraryItemId];
                  return LListTile(
                    leading: LPosterTile(width: 44, imageProvider: posterImageFor(ref, MediaType.tv, show?.posterPath)),
                    title: '${show?.title ?? 'Unknown show'} — S${episode.seasonNumber}E${episode.episodeNumber}',
                    subtitle: episode.title,
                    trailing: LStarRating(rating: episode.rating, maxRating: 6, size: 14),
                    onTap: show == null
                        ? null
                        : () => context.push(Routes.libraryTvDetail.replaceFirst(':id', show.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
