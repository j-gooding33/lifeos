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

enum _BookSegment { toRead, reading, read }

/// Books' watchlist home — the film/TV grid pattern, with §22's own
/// vocabulary ("to read"/"reading"/"read" rather than "watch") laid over
/// the same wishlist/inProgress/done statuses.
class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  var _segment = _BookSegment.toRead;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Top 3',
            onPressed: () => context.push(Routes.libraryBookTop3),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Ratings',
            onPressed: () => context.push(Routes.libraryBookRatings),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push(Routes.libraryBooksSearch),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(LifeSpace.s16),
            child: LSegmented<_BookSegment>(
              segments: const {
                _BookSegment.toRead: 'To read',
                _BookSegment.reading: 'Reading',
                _BookSegment.read: 'Read',
              },
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          Expanded(child: _buildSegment()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.libraryBooksSearch),
        tooltip: 'Add a book',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSegment() {
    switch (_segment) {
      case _BookSegment.toRead:
        final provider = libraryByStatusProvider(MediaType.book, LibraryItemStatus.wishlist);
        return _BookGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Your reading list is empty',
          emptyMessage: 'Search for a book to add it.',
          onRetry: () => ref.invalidate(provider),
        );
      case _BookSegment.reading:
        final provider = libraryByStatusProvider(MediaType.book, LibraryItemStatus.inProgress);
        return _BookGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: "Nothing you're reading",
          emptyMessage: 'Mark a book as reading from its detail page.',
          onRetry: () => ref.invalidate(provider),
        );
      case _BookSegment.read:
        final provider = libraryByStatusProvider(MediaType.book, LibraryItemStatus.done);
        return _BookGrid(
          asyncItems: ref.watch(provider),
          emptyTitle: 'Nothing finished yet',
          emptyMessage: 'Mark a book as finished to see it here.',
          onRetry: () => ref.invalidate(provider),
        );
    }
  }
}

class _BookGrid extends ConsumerWidget {
  const _BookGrid({
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
      error: (error, stack) => LErrorState(message: "Couldn't load your books.", onRetry: onRetry),
      data: (items) {
        if (items.isEmpty) {
          return LEmptyState(icon: Icons.menu_book_outlined, title: emptyTitle, message: emptyMessage);
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
          itemBuilder: (context, index) => _BookTile(item: items[index]),
        );
      },
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({required this.item});

  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => context.push(Routes.libraryBookDetail.replaceFirst(':id', item.id)),
      onLongPressStart: (details) =>
          showLibraryItemMenu(context, ref, item, position: details.globalPosition, doneVerb: 'Finished'),
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
                      imageProvider: posterImageFor(ref, MediaType.book, item.posterPath),
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
