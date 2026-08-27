import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
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

const _typeIcons = {
  MediaType.film: Icons.movie_outlined,
  MediaType.tv: Icons.tv_outlined,
  MediaType.book: Icons.menu_book_outlined,
};

const _typeDetailRoutes = {
  MediaType.film: Routes.libraryFilmDetail,
  MediaType.tv: Routes.libraryTvDetail,
  MediaType.book: Routes.libraryBookDetail,
};

/// M8.15: every 1-5★ rating across Films/TV/Books in one newest-first
/// list — TV episode ratings (1-6★, a different scale entirely per Part
/// 42) have their own screen and aren't mixed in here.
class UnifiedRatingsScreen extends ConsumerWidget {
  const UnifiedRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncFilms = ref.watch(libraryRatedProvider(MediaType.film));
    final asyncTv = ref.watch(libraryRatedProvider(MediaType.tv));
    final asyncBooks = ref.watch(libraryRatedProvider(MediaType.book));

    final lists = [asyncFilms, asyncTv, asyncBooks];
    final loading = lists.any((a) => a.isLoading);
    final hasError = lists.any((a) => a.hasError);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('All ratings')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? LErrorState(
              message: "Couldn't load your ratings.",
              onRetry: () {
                ref
                  ..invalidate(libraryRatedProvider(MediaType.film))
                  ..invalidate(libraryRatedProvider(MediaType.tv))
                  ..invalidate(libraryRatedProvider(MediaType.book));
              },
            )
          : _buildList(context, ref, asyncFilms.requireValue, asyncTv.requireValue, asyncBooks.requireValue),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<AppLibraryItem> films,
    List<AppLibraryItem> tv,
    List<AppLibraryItem> books,
  ) {
    final all = [...films, ...tv, ...books];
    if (all.isEmpty) {
      return const LEmptyState(
        icon: Icons.star_border,
        title: 'No ratings yet',
        message: 'Rate a film, show, or book to see it here.',
      );
    }
    DateTime dateOf(AppLibraryItem i) => i.finishedAt ?? i.addedAt;
    all.sort((a, b) => dateOf(b).compareTo(dateOf(a)));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
      itemCount: all.length,
      separatorBuilder: (_, _) => const SizedBox(height: LifeSpace.s4),
      itemBuilder: (context, index) {
        final item = all[index];
        final colors = context.colors;
        return LListTile(
          leading: Stack(
            children: [
              LPosterTile(width: 44, imageProvider: posterImageFor(ref, item.mediaType, item.posterPath)),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: colors.neutrals.surface, shape: BoxShape.circle),
                  child: Icon(_typeIcons[item.mediaType], size: 12, color: colors.neutrals.ink2),
                ),
              ),
            ],
          ),
          title: item.title,
          subtitle: item.year?.toString(),
          trailing: LStarRating(rating: item.rating, size: 14),
          onTap: () => context.push(_typeDetailRoutes[item.mediaType]!.replaceFirst(':id', item.id)),
        );
      },
    );
  }
}
