import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_menu.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/features/library/application/library_providers.dart';
import 'package:life_os/features/library/presentation/widgets/mark_watched_sheet.dart';
import 'package:life_os/features/library/presentation/widgets/rate_dialog.dart';

/// One shared long-press/overflow menu for films, TV shows and books (§16)
/// — the actions (mark done, rate, favourite, add to Top list, remove) are
/// identical across all three; only [doneVerb] differs ("Watched" vs
/// "Finished").
Future<void> showLibraryItemMenu(
  BuildContext context,
  WidgetRef ref,
  AppLibraryItem item, {
  required Offset position,
  String doneVerb = 'Watched',
}) {
  final repository = ref.read(libraryItemRepositoryProvider);
  final topLists = ref.read(topListRepositoryProvider);

  return LMenu.showAt(
    context: context,
    position: position,
    items: [
      if (item.status == LibraryItemStatus.done)
        LMenuItem(
          label: 'Mark not $doneVerb',
          icon: Icons.replay_outlined,
          onTap: () => repository.setStatus(item.id, status: LibraryItemStatus.wishlist),
        )
      else
        LMenuItem(
          label: 'Mark $doneVerb',
          icon: Icons.check_circle_outline,
          onTap: () => MarkWatchedSheet.show(context, item, verb: doneVerb),
        ),
      LMenuItem(
        label: item.isRated ? 'Change rating' : 'Rate',
        icon: Icons.star_border,
        onTap: () => RateDialog.show(context, ref, item),
      ),
      LMenuItem(
        label: item.isFavourite ? 'Remove favourite' : 'Add favourite',
        icon: item.isFavourite ? Icons.favorite : Icons.favorite_border,
        onTap: () => repository.setFavourite(item.id, isFavourite: !item.isFavourite),
      ),
      LMenuItem(
        label: 'Add to Top list',
        icon: Icons.emoji_events_outlined,
        onTap: () async {
          final userId = await ref.read(currentUserIdProvider.future);
          final result = await topLists.add(userId, item.mediaType, item.id);
          if (!context.mounted) return;
          result.when(
            ok: (_) => LToast.show(context, 'Added to your Top list'),
            err: (f) => LToast.show(context, f.message),
          );
        },
      ),
      LMenuItem(
        label: 'Remove',
        icon: Icons.delete_outline,
        destructive: true,
        onTap: () async {
          final confirmed = await LConfirmDialog.show(
            context,
            title: 'Remove ${item.title}?',
            message: 'This removes it from your library entirely.',
          );
          if (confirmed) await repository.remove(item.id);
        },
      ),
    ],
  );
}
