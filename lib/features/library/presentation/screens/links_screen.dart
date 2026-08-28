import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_link.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_prompt_dialog.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/features/library/application/link_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// §17.3. A saved URL, title, and tags — "the link is saved instantly and
/// enriched later." Enrichment (favicon, OG title) isn't built; see
/// DECISIONS.md.
class LinksScreen extends ConsumerWidget {
  const LinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncLinks = ref.watch(allLinksProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Links'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Save a link', onPressed: () => _addLink(context, ref)),
        ],
      ),
      body: asyncLinks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LErrorState(message: "Couldn't load your links.", onRetry: () => ref.invalidate(allLinksProvider)),
        data: (links) {
          if (links.isEmpty) {
            return LEmptyState(
              icon: Icons.link,
              title: 'No links yet',
              message: 'Save a URL with the + button — instantly, no connection needed.',
              actionLabel: 'Save a link',
              onAction: () => _addLink(context, ref),
            );
          }
          return ListView.separated(
            itemCount: links.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _LinkRow(link: links[index]),
          );
        },
      ),
    );
  }

  Future<void> _addLink(BuildContext context, WidgetRef ref) async {
    final url = await LPromptDialog.show(context, title: 'Save a link', label: 'URL');
    if (url == null || !context.mounted) return;
    final normalised = url.startsWith('http://') || url.startsWith('https://') ? url : 'https://$url';
    final userId = await ref.read(currentUserIdProvider.future);
    final result = await ref.read(linkRepositoryProvider).createLink(userId: userId, url: normalised);
    if (!context.mounted) return;
    result.when(ok: (_) {}, err: (f) => LToast.show(context, f.message));
  }
}

class _LinkRow extends ConsumerWidget {
  const _LinkRow({required this.link});

  final AppLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LListTile(
      leading: const Icon(Icons.link),
      title: link.displayTitle,
      subtitle: link.displayTitle == link.url ? null : link.url,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        tooltip: 'Delete',
        onPressed: () => _confirmDelete(context, ref),
      ),
      onTap: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) LToast.show(context, "Couldn't open that link");
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this link?', message: 'This cannot be undone.');
    if (confirmed) {
      await ref.read(linkRepositoryProvider).deleteLink(link.id);
    }
  }
}
