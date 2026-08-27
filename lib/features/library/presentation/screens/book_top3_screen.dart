import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/routing/routes.dart';

/// "My Top 3 Books" — same `film_top5_screen.dart` machinery; the cap of 3
/// (vs. 5 for film/TV) comes entirely from `TopListRepository.capFor`, no
/// separate logic needed here.
class BookTop3Screen extends ConsumerWidget {
  const BookTop3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    const type = MediaType.book;
    final entriesAsync = ref.watch(topListProvider(type));
    final itemsAsync = ref.watch(libraryAllProvider(type));
    final repository = ref.read(topListRepositoryProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Top 3 books')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your Top 3.", onRetry: () => ref.invalidate(topListProvider(type))),
        data: (entries) {
          return itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => LErrorState(message: "Couldn't load your books.", onRetry: () => ref.invalidate(libraryAllProvider(type))),
            data: (allItems) {
              final byId = {for (final i in allItems) i.id: i};
              final ranked = [
                for (final e in entries)
                  if (byId[e.libraryItemId] case final item?) (entry: e, item: item),
              ];
              return Column(
                children: [
                  Expanded(
                    child: ranked.isEmpty
                        ? const LEmptyState(
                            icon: Icons.emoji_events_outlined,
                            title: 'No Top 3 yet',
                            message: 'Add your favourite books below. A high star rating never adds one automatically.',
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s16, vertical: LifeSpace.s8),
                            itemCount: ranked.length,
                            onReorderItem: (oldIndex, newIndex) {
                              final ids = ranked.map((r) => r.item.id).toList();
                              final id = ids.removeAt(oldIndex);
                              ids.insert(newIndex, id);
                              _reorder(ref, type, ids);
                            },
                            itemBuilder: (context, index) {
                              final row = ranked[index];
                              return LListTile(
                                key: ValueKey(row.entry.id),
                                leading: SizedBox(
                                  width: 60,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${row.entry.rank}', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink2)),
                                      const SizedBox(width: LifeSpace.s8),
                                      LPosterTile(width: 36, imageProvider: posterImageFor(ref, type, row.item.posterPath)),
                                    ],
                                  ),
                                ),
                                title: row.item.title,
                                subtitle: row.item.creators.isNotEmpty ? row.item.creators.join(', ') : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Remove from Top 3',
                                  onPressed: () async {
                                    final userId = await ref.read(currentUserIdProvider.future);
                                    await repository.remove(userId, type, row.item.id);
                                  },
                                ),
                                onTap: () => context.push(Routes.libraryBookDetail.replaceFirst(':id', row.item.id)),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(LifeSpace.s16),
                    child: LButton(
                      label: ranked.length >= repository.capFor(type) ? 'Top 3 is full' : 'Add a book',
                      onPressed: ranked.length >= repository.capFor(type)
                          ? null
                          : () => _showPicker(context, ref, type, allItems, entries.map((e) => e.libraryItemId).toSet()),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _reorder(WidgetRef ref, MediaType type, List<String> orderedIds) async {
    final userId = await ref.read(currentUserIdProvider.future);
    await ref.read(topListRepositoryProvider).reorder(userId, type, orderedIds);
  }

  Future<void> _showPicker(
    BuildContext context,
    WidgetRef ref,
    MediaType type,
    List<AppLibraryItem> allItems,
    Set<String> excludeIds,
  ) {
    final candidates = allItems.where((i) => !excludeIds.contains(i.id)).toList();
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.7],
      builder: (context) {
        if (candidates.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(LifeSpace.s24),
            child: LEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Nothing to add',
              message: 'Add a book to your library first.',
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(LifeSpace.s16),
          itemCount: candidates.length,
          itemBuilder: (context, index) {
            final item = candidates[index];
            return LListTile(
              leading: LPosterTile(width: 40, imageProvider: posterImageFor(ref, type, item.posterPath)),
              title: item.title,
              subtitle: item.creators.isNotEmpty ? item.creators.join(', ') : null,
              onTap: () async {
                final userId = await ref.read(currentUserIdProvider.future);
                final result = await ref.read(topListRepositoryProvider).add(userId, type, item.id);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                result.when(
                  ok: (_) {},
                  err: (f) => LToast.show(context, f.message),
                );
              },
            );
          },
        );
      },
    );
  }
}
