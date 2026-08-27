import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_loading_shimmer.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_segmented.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/features/library/presentation/widgets/library_item_menu.dart';
import 'package:life_os/routing/routes.dart';

enum _FilmSegment { watchlist, watched, favourites }

/// M8 Part 3: the film watchlist/library home — segmented by status, a
/// poster grid, and the shared long-press menu for quick actions.
class FilmsScreen extends ConsumerStatefulWidget {
  const FilmsScreen({super.key});

  @override
  ConsumerState<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends ConsumerState<FilmsScreen> {
  var _segment = _FilmSegment.watchlist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Films'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Stats',
            onPressed: () => context.push(Routes.libraryFilmStats),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Top 5',
            onPressed: () => context.push(Routes.libraryFilmTop5),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Ratings',
            onPressed: () => context.push(Routes.libraryFilmRatings),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push(Routes.libraryFilmsSearch),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_FilmSegment>(
              segments: const {
                _FilmSegment.watchlist: 'Watchlist',
                _FilmSegment.watched: 'Watched',
                _FilmSegment.favourites: 'Favourites',
              },
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(child: _buildSegment()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.libraryFilmsSearch),
        tooltip: 'Add a film',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSegment() {
    switch (_segment) {
      case _FilmSegment.watchlist:
        final provider = libraryByStatusProvider(MediaType.film, LibraryItemStatus.wishlist);
        return _FilmGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Your watchlist is empty',
          emptyMessage: 'Search for a film to add it.',
          onRetry: () => ref.invalidate(provider),
        );
      case _FilmSegment.watched:
        final provider = libraryByStatusProvider(MediaType.film, LibraryItemStatus.done);
        return _FilmGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Nothing watched yet',
          emptyMessage: 'Mark a film as watched to see it here.',
          onRetry: () => ref.invalidate(provider),
        );
      case _FilmSegment.favourites:
        final provider = libraryFavouritesProvider(MediaType.film);
        return _FilmGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'No favourites yet',
          emptyMessage: 'Mark a film as a favourite from its detail page.',
          onRetry: () => ref.invalidate(provider),
        );
    }
  }
}

class _FilmGrid extends ConsumerWidget {
  const _FilmGrid({
    required this.asyncItems,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRetry,
  });

  final AsyncValue<List<AppLibraryItem>> asyncItems;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncItems.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(LifeSpace.s16),
        child: Wrap(
          spacing: LifeSpace.s16,
          runSpacing: LifeSpace.s16,
          children: [
            LLoadingShimmer(width: 104, height: 156),
            LLoadingShimmer(width: 104, height: 156),
            LLoadingShimmer(width: 104, height: 156),
          ],
        ),
      ),
      error: (error, stack) => LErrorState(message: "Couldn't load your films.", onRetry: onRetry),
      data: (items) {
        if (items.isEmpty) {
          return LEmptyState(icon: Icons.movie_outlined, title: emptyTitle, message: emptyMessage);
        }
        return GridView.builder(
          padding: const EdgeInsets.all(LifeSpace.s16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: LifeSpace.s16,
            crossAxisSpacing: LifeSpace.s16,
            childAspectRatio: 0.56,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _FilmTile(item: items[index]),
        );
      },
    );
  }
}

class _FilmTile extends ConsumerWidget {
  const _FilmTile({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => context.push(Routes.libraryFilmDetail.replaceFirst(':id', item.id)),
      onLongPressStart: (details) => showLibraryItemMenu(context, ref, item, position: details.globalPosition),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) => LPosterTile(
                      width: constraints.maxWidth,
                      imageProvider: posterImageFor(ref, MediaType.film, item.posterPath),
                    ),
                  ),
                ),
                if (item.isFavourite)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.favorite, size: 16, color: colors.semantic('danger').base),
                  ),
              ],
            ),
          ),
          const SizedBox(height: LifeSpace.s4),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(color: colors.neutrals.ink),
          ),
        ],
      ),
    );
  }
}
