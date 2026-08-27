import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_stat.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/routing/routes.dart';

/// M8.15: the Library tab's landing page — a unified overview (a live
/// count per media type) plus a hub linking to each section. Films/TV/
/// Books are real; Notes/Links still route to their existing placeholders
/// until their own milestones land.
class LibraryHomeScreen extends ConsumerWidget {
  const LibraryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'All ratings',
            onPressed: () => context.push(Routes.libraryAllRatings),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(LifeSpace.s20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountStat(type: MediaType.film, caption: 'FILMS'),
                _CountStat(type: MediaType.tv, caption: 'SHOWS'),
                _CountStat(type: MediaType.book, caption: 'BOOKS'),
              ],
            ),
          ),
          LListTile(
            leading: const Icon(Icons.movie_outlined),
            title: 'Films',
            subtitle: 'Watchlist, ratings, Top 5',
            onTap: () => context.push(Routes.libraryFilms),
          ),
          LListTile(
            leading: const Icon(Icons.tv_outlined),
            title: 'TV Shows',
            subtitle: 'Episodes, ratings, Top 5',
            onTap: () => context.push(Routes.libraryTv),
          ),
          LListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: 'Books',
            subtitle: 'Reading list, ratings, Top 3',
            onTap: () => context.push(Routes.libraryBooks),
          ),
          LListTile(
            leading: const Icon(Icons.note_outlined),
            title: 'Notes',
            onTap: () => context.push(Routes.libraryNotes),
          ),
          LListTile(
            leading: const Icon(Icons.link),
            title: 'Links',
            onTap: () => context.push(Routes.libraryLinks),
          ),
        ],
      ),
    );
  }
}

class _CountStat extends ConsumerWidget {
  const _CountStat({required this.type, required this.caption});

  final MediaType type;
  final String caption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(libraryAllProvider(type)).value?.length;
    return LStat(value: count == null ? '—' : '$count', caption: caption);
  }
}
