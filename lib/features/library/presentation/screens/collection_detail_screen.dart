import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_collection.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/components/l_poster_tile.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/media_poster.dart';
import 'package:life_os/routing/routes.dart';

const _typeDetailRoutes = {
  MediaType.film: Routes.libraryFilmDetail,
  MediaType.tv: Routes.libraryTvDetail,
  MediaType.book: Routes.libraryBookDetail,
};

/// M8 Part 28. One collection's items — a poster grid spanning whichever
/// media types were added, since a collection is polymorphic (§15.2).
/// Removing an item here only removes it from the collection; the item
/// itself is untouched (see `showLibraryItemMenu`'s "Remove" for deleting
/// it from the library entirely).
class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncCollection = ref.watch(collectionByIdProvider(collectionId));
    final asyncItems = ref.watch(collectionItemsProvider(collectionId));

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: Text(asyncCollection.value?.title ?? 'Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: asyncCollection.value == null ? null : () => _rename(context, ref, asyncCollection.value!),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete collection', onPressed: () => _delete(context, ref)),
        ],
      ),
      body: asyncItems.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            LErrorState(message: "Couldn't load this collection.", onRetry: () => ref.invalidate(collectionItemsProvider(collectionId))),
        data: (items) {
          if (items.isEmpty) {
            return const LEmptyState(
              icon: Icons.collections_bookmark_outlined,
              title: 'Nothing here yet',
              message: 'Add a film, show or book to this collection from its own menu.',
            );
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
            itemBuilder: (context, index) => _CollectionItemTile(collectionId: collectionId, item: items[index]),
          );
        },
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, AppCollection collection) async {
    final controller = TextEditingController(text: collection.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename collection'),
        content: LTextField(controller: controller, label: 'Title', outlined: true, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (title == null || title.isEmpty || !context.mounted) return;
    await ref.read(collectionRepositoryProvider).rename(collection.id, title);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(
      context,
      title: 'Delete this collection?',
      message: 'The films, shows and books in it stay in your library.',
    );
    if (!confirmed) return;
    await ref.read(collectionRepositoryProvider).delete(collectionId);
    if (context.mounted) context.pop();
  }
}

class _CollectionItemTile extends ConsumerWidget {
  const _CollectionItemTile({required this.collectionId, required this.item});

  final String collectionId;
  final AppLibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push(_typeDetailRoutes[item.mediaType]!.replaceFirst(':id', item.id)),
      onLongPressStart: (details) => _showRemoveMenu(context, ref, details.globalPosition),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  LPosterTile(width: constraints.maxWidth, imageProvider: posterImageFor(ref, item.mediaType, item.posterPath)),
            ),
          ),
          const SizedBox(height: LifeSpace.s4),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.caption.copyWith(color: context.colors.neutrals.ink),
          ),
        ],
      ),
    );
  }

  Future<void> _showRemoveMenu(BuildContext context, WidgetRef ref, Offset position) {
    return LMenu.showAt(
      context: context,
      position: position,
      items: [
        LMenuItem(
          label: 'Remove from collection',
          icon: Icons.remove_circle_outline,
          destructive: true,
          onTap: () => ref.read(collectionRepositoryProvider).removeItem(collectionId, item.id),
        ),
      ],
    );
  }
}
