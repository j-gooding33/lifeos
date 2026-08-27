import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/routing/routes.dart';

/// The Library tab's landing page — a hub linking to each section. Films is
/// the first section built out for real (M8); the rest still route to
/// their existing placeholders until their own milestones land.
class LibraryHomeScreen extends StatelessWidget {
  const LibraryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        children: [
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
