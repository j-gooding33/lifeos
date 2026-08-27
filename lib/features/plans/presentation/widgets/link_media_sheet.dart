import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/data/media/media_types.dart';
import 'package:life_os/data/repositories/models/app_library_item.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_sheet.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/plans/application/plan_providers.dart';

const _typeNouns = {MediaType.film: 'film', MediaType.tv: 'show', MediaType.book: 'book'};
const _typeIcons = {MediaType.film: Icons.movie_outlined, MediaType.tv: Icons.tv_outlined, MediaType.book: Icons.menu_book_outlined};

/// §16.5 "choose a film/show/book" — picks among the user's own unwatched
/// library items of [mediaType]. Adding something new to the library is a
/// separate flow (Library search); this only links what's already saved.
class LinkMediaSheet extends ConsumerWidget {
  const LinkMediaSheet({required this.mediaType, required this.onPicked, super.key});

  final MediaType mediaType;
  final ValueChanged<AppLibraryItem> onPicked;

  static Future<void> show(BuildContext context, {required MediaType mediaType, required ValueChanged<AppLibraryItem> onPicked}) {
    return LSheet.show<void>(
      context: context,
      snapPoints: const [0.7],
      builder: (context) => LinkMediaSheet(mediaType: mediaType, onPicked: onPicked),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noun = _typeNouns[mediaType]!;
    final asyncItems = ref.watch(unwatchedLibraryItemsProvider(mediaType));
    return asyncItems.when(
      loading: () => const Padding(padding: EdgeInsets.all(LifeSpace.s24), child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(LifeSpace.s24),
        child: LErrorState(
          message: "Couldn't load your library.",
          onRetry: () => ref.invalidate(unwatchedLibraryItemsProvider(mediaType)),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(LifeSpace.s24),
            child: LEmptyState(
              icon: _typeIcons[mediaType]!,
              title: 'Nothing to choose from',
              message: 'Add a $noun to your library first, then come back here.',
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return LListTile(
              leading: Icon(_typeIcons[mediaType]),
              title: item.title,
              subtitle: item.year?.toString(),
              onTap: () {
                Navigator.of(context).pop();
                onPicked(item);
              },
            );
          },
        );
      },
    );
  }
}
