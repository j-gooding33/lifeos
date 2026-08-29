import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/utils/byte_format.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/data_settings_providers.dart';

/// §22.5, §18.2. Export/import and "rebuild statistics" aren't built (the
/// former is a meaningfully bigger feature, the latter has no rollup
/// pipeline yet — see DECISIONS.md).
class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncSize = ref.watch(databaseSizeBytesProvider);
    final asyncDocsSize = ref.watch(documentStorageBytesProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(title: const Text('Data')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: LifeSpace.s8),
        children: [
          LListTile(
            title: 'Storage used',
            subtitle: asyncSize.when(
              data: formatBytes,
              loading: () => 'Calculating…',
              error: (error, stack) => "Couldn't calculate",
            ),
          ),
          LListTile(
            title: 'Documents storage',
            subtitle: asyncDocsSize.when(
              data: (bytes) => '${formatBytes(bytes)} of 25MB per file',
              loading: () => 'Calculating…',
              error: (error, stack) => "Couldn't calculate",
            ),
          ),
          LListTile(
            title: 'Rebuild search index',
            subtitle: 'Fixes search if results look wrong or incomplete.',
            onTap: () => _rebuildSearchIndex(context, ref),
          ),
          LListTile(
            title: 'Clear image cache',
            subtitle: 'Posters and covers re-download next time they scroll into view.',
            onTap: () => _clearImageCache(context),
          ),
        ],
      ),
    );
  }

  Future<void> _rebuildSearchIndex(BuildContext context, WidgetRef ref) async {
    await ref.read(dataSettingsSearchRepositoryProvider).rebuild();
    if (context.mounted) LToast.show(context, 'Search index rebuilt');
  }

  Future<void> _clearImageCache(BuildContext context) async {
    await DefaultCacheManager().emptyCache();
    if (context.mounted) LToast.show(context, 'Image cache cleared');
  }
}
