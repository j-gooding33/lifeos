import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/routing/routes.dart';

/// M8 Part 28 (§15.2). Manual collections only — a flat, named list of
/// collections; items are added to one from the film/TV/book long-press
/// menu (`AddToCollectionSheet`), not from here.
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncCollections = ref.watch(collectionsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Collections')),
      body: asyncCollections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            LErrorState(message: "Couldn't load your collections.", onRetry: () => ref.invalidate(collectionsProvider)),
        data: (collectionsList) {
          if (collectionsList.isEmpty) {
            return const LEmptyState(
              icon: Icons.collections_bookmark_outlined,
              title: 'No collections yet',
              message: 'Create one with the + button, then add films, shows or books to it from their menu.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
            itemCount: collectionsList.length,
            itemBuilder: (context, index) {
              final collection = collectionsList[index];
              return LListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: collection.title,
                subtitle: collection.description,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.libraryCollectionDetail.replaceFirst(':id', collection.id)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCollection(context, ref),
        tooltip: 'New collection',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createCollection(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New collection'),
        content: LTextField(controller: controller, label: 'Title', outlined: true, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (title == null || title.isEmpty || !context.mounted) return;
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref.read(collectionRepositoryProvider).create(userId: userId, title: title);
    if (!context.mounted) return;
    result.when(ok: (_) {}, err: (f) => LToast.show(context, f.message));
  }
}
