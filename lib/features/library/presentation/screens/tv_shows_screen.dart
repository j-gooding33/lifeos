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

enum _TvSegment { watchlist, watching, watched }

/// TV's watchlist home — same grid/menu machinery as `films_screen.dart`,
/// with a "Watching" segment in the middle (`inProgress`) that films don't
/// bother exposing, since a show is far more often mid-way-through than a
/// two-hour film is.
class TvShowsScreen extends ConsumerStatefulWidget {
  const TvShowsScreen({super.key});

  @override
  ConsumerState<TvShowsScreen> createState() => _TvShowsScreenState();
}

class _TvShowsScreenState extends ConsumerState<TvShowsScreen> {
  var _segment = _TvSegment.watchlist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('TV Shows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Stats',
            onPressed: () => context.push(Routes.libraryTvStats),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Top 5',
            onPressed: () => context.push(Routes.libraryTvTop5),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Ratings',
            onPressed: () => context.push(Routes.libraryTvShowRatings),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push(Routes.libraryTvSearch),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_TvSegment>(
              segments: const {
                _TvSegment.watchlist: 'Watchlist',
                _TvSegment.watching: 'Watching',
                _TvSegment.watched: 'Watched',
              },
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(child: _buildSegment()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.libraryTvSearch),
        tooltip: 'Add a show',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSegment() {
    switch (_segment) {
      case _TvSegment.watchlist:
        final provider = libraryByStatusProvider(MediaType.tv, LibraryItemStatus.wishlist);
        return _TvGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Your watchlist is empty',
          emptyMessage: 'Search for a show to add it.',
          onRetry: () => ref.invalidate(provider),
        );
      case _TvSegment.watching:
        final provider = libraryByStatusProvider(MediaType.tv, LibraryItemStatus.inProgress);
        return _TvGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Nothing in progress',
          emptyMessage: 'Mark a show as watching from its detail page.',
          onRetry: () => ref.invalidate(provider),
        );
      case _TvSegment.watched:
        final provider = libraryByStatusProvider(MediaType.tv, LibraryItemStatus.done);
        return _TvGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Nothing watched yet',
          emptyMessage: 'Mark a show as watched to see it here.',
          onRetry: () => ref.invalidate(provider),
        );
    }
  }
}

class _TvGrid extends ConsumerWidget {
  const _TvGrid({
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
      error: (error, stack) => LErrorState(message: "Couldn't load your shows.", onRetry: onRetry),
      data: (items) {
        if (items.isEmpty) {
          return LEmptyState(icon: Icons.tv_outlined, title: emptyTitle, message: emptyMessage);
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
          itemBuilder: (context, index) => _TvTile(item: items[index]),
        );
      },
    );
  }
}

class _TvTile extends ConsumerWidget {
  const _TvTile({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => context.push(Routes.libraryTvDetail.replaceFirst(':id', item.id)),
      onLongPressStart: (details) =>
          showLibraryItemMenu(context, ref, item, position: details.globalPosition),
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
                      imageProvider: posterImageFor(ref, MediaType.tv, item.posterPath),
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
