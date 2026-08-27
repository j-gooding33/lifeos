import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/components/l_text_field.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/library/application/library_providers.dart';

/// M8 Part 28. Reached from `showLibraryItemMenu`'s "Add to collection" —
/// lists every collection with a checkmark for ones [item] already
/// belongs to; tapping toggles membership. "New collection" creates one
/// and adds [item] to it in the same action.
class AddToCollectionSheet extends ConsumerWidget {
  const AddToCollectionSheet({required this.item, super.key});

  final AppLibraryItem item;

  static Future<void> show(BuildContext context, AppLibraryItem item) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.6],
      builder: (context) => AddToCollectionSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncCollections = ref.watch(collectionsProvider);
    final asyncMemberOf = ref.watch(collectionIdsContainingProvider(item.id));
    final repository = ref.read(collectionRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(LifeSpace.s20, LifeSpace.s20, LifeSpace.s20, LifeSpace.s8),
          child: Text('Add to collection', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
        ),
        LListTile(leading: const Icon(Icons.add), title: 'New collection', onTap: () => _createAndAdd(context, ref)),
        const Divider(height: 1),
        Flexible(
          child: asyncCollections.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(LifeSpace.s24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) =>
                LErrorState(message: "Couldn't load your collections.", onRetry: () => ref.invalidate(collectionsProvider)),
            data: (collectionsList) {
              if (collectionsList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(LifeSpace.s24),
                  child: LEmptyState(
                    icon: Icons.collections_bookmark_outlined,
                    title: 'No collections yet',
                    message: 'Create one above.',
                  ),
                );
              }
              final memberOf = asyncMemberOf.value ?? const <String>{};
              return ListView.builder(
                shrinkWrap: true,
                itemCount: collectionsList.length,
                itemBuilder: (context, index) {
                  final collection = collectionsList[index];
                  final isMember = memberOf.contains(collection.id);
                  return LListTile(
                    leading: Icon(
                      isMember ? Icons.check_circle : Icons.circle_outlined,
                      color: isMember ? colors.accent.base : colors.neutrals.ink2,
                    ),
                    title: collection.title,
                    onTap: () async {
                      final result = isMember
                          ? await repository.removeItem(collection.id, item.id)
                          : await repository.addItem(collection.id, item.id);
                      if (!context.mounted) return;
                      result.when(ok: (_) {}, err: (f) => LToast.show(context, f.message));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createAndAdd(BuildContext context, WidgetRef ref) async {
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
    result.when(
      ok: (collection) => unawaited(ref.read(collectionRepositoryProvider).addItem(collection.id, item.id)),
      err: (f) => LToast.show(context, f.message),
    );
  }
}
