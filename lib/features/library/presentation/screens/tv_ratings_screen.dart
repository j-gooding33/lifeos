import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/components/l_star_rating.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/routing/routes.dart';

enum _RatingSort { newest, oldest, highest, lowest }

/// Show-level ratings (1-5★) — mirrors `film_ratings_screen.dart`. Episode
/// ratings (1-6★) have their own history screen
/// (`tv_episode_ratings_screen.dart`), since the two scales aren't
/// comparable in one sorted list (Part 42).
class TvRatingsScreen extends ConsumerStatefulWidget {
  const TvRatingsScreen({super.key});

  @override
  ConsumerState<TvRatingsScreen> createState() => _TvRatingsScreenState();
}

class _TvRatingsScreenState extends ConsumerState<TvRatingsScreen> {
  var _sort = _RatingSort.newest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = libraryRatedProvider(MediaType.tv);
    final asyncItems = ref.watch(provider);
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('TV ratings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Episode ratings',
            onPressed: () => context.push(Routes.libraryTvEpisodeRatings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_RatingSort>(
              segments: const {
                _RatingSort.newest: 'Newest',
                _RatingSort.oldest: 'Oldest',
                _RatingSort.highest: 'Highest',
                _RatingSort.lowest: 'Lowest',
              },
              selected: _sort,
              onChanged: (value) => setState(() => _sort = value),
            ),
          ),
          Expanded(
            child: asyncItems.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: LifeSpace.s16),
                child: Column(children: [LLoadingShimmer(height: 56), SizedBox(height: LifeSpace.s8), LLoadingShimmer(height: 56)]),
              ),
              error: (error, stack) => LErrorState(message: "Couldn't load your ratings.", onRetry: () => ref.invalidate(provider)),
              data: (items) {
                if (items.isEmpty) {
                  return const LEmptyState(
                    icon: Icons.star_border,
                    title: 'No rated shows yet',
                    message: 'Rate a show from its detail page to see it here.',
                  );
                }
                final sorted = _sorted(items);
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
                  itemBuilder: (context, index) {
                    final item = sorted[index];
                    return LListTile(
                      leading: LPosterTile(width: 44, imageProvider: posterImageFor(ref, MediaType.tv, item.posterPath)),
                      title: item.title,
                      subtitle: item.year?.toString(),
                      trailing: LStarRating(rating: item.rating, size: 16),
                      onTap: () => context.push(Routes.libraryTvDetail.replaceFirst(':id', item.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<AppLibraryItem> _sorted(List<AppLibraryItem> items) {
    final list = [...items];
    DateTime dateOf(AppLibraryItem i) => i.finishedAt ?? i.addedAt;
    switch (_sort) {
      case _RatingSort.newest:
        list.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
      case _RatingSort.oldest:
        list.sort((a, b) => dateOf(a).compareTo(dateOf(b)));
      case _RatingSort.highest:
        list.sort((a, b) {
          final byRating = (b.rating ?? 0).compareTo(a.rating ?? 0);
          return byRating != 0 ? byRating : dateOf(b).compareTo(dateOf(a));
        });
      case _RatingSort.lowest:
        list.sort((a, b) {
          final byRating = (a.rating ?? 0).compareTo(b.rating ?? 0);
          return byRating != 0 ? byRating : dateOf(b).compareTo(dateOf(a));
        });
    }
    return list;
  }
}
