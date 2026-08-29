import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/data_transfer/data_import_service.dart';
import 'package:life_os/core/data_transfer/data_transfer_providers.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/utils/byte_format.dart';
import 'package:life_os/design/components/l_button.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:life_os/features/settings/application/data_settings_providers.dart';

/// §22.5, §18.2, §27.5. "Rebuild statistics" isn't built (no rollup
/// pipeline exists yet). Export/import are real but JSON-only — the
/// spec's ZIP-bundled CSV export and CSV import mapping aren't built —
/// see DECISIONS.md.
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
          LListTile(
            title: 'Export data',
            subtitle: "A JSON file of everything you've entered, ready to share or back up.",
            onTap: () => _exportData(context, ref),
          ),
          LListTile(
            title: 'Import data',
            subtitle: 'From a Life OS export. Always adds — nothing existing is changed or removed.',
            onTap: () => _importData(context, ref),
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

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dataExportServiceProvider).shareExport();
    } on Object {
      if (context.mounted) LToast.show(context, "Couldn't export your data.");
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;

    final Map<String, Object?> parsed;
    try {
      final decoded = jsonDecode(await File(path).readAsString());
      if (decoded is! Map<String, Object?>) throw const FormatException('not a Life OS export');
      parsed = decoded;
    } on Object {
      if (context.mounted) LToast.show(context, "That doesn't look like a Life OS export file.");
      return;
    }

    final importService = ref.read(dataImportServiceProvider);
    final preview = importService.preview(parsed);
    if (preview.totalRows == 0) {
      if (context.mounted) LToast.show(context, 'Nothing to import — that file has no rows.');
      return;
    }
    if (!context.mounted) return;

    final confirmed = await _ImportPreviewDialog.show(context, preview);
    if (!confirmed || !context.mounted) return;

    final userId = await ref.read(currentUserIdProvider.future);
    await importService.import(parsed, currentUserId: userId);
    if (context.mounted) LToast.show(context, 'Imported ${preview.totalRows} rows.');
  }
}

/// A plain confirm dialog, not `LConfirmDialog` — that component hardcodes
/// its confirm button to the destructive variant, which would misrepresent
/// an additive, non-destructive action.
class _ImportPreviewDialog {
  const _ImportPreviewDialog._();

  static Future<bool> show(BuildContext context, ImportPreview preview) async {
    final colors = context.colors;
    final sortedTables = preview.countsByTable.keys.toList()..sort();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: colors.neutrals.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: LifeSpace.s20, vertical: LifeSpace.s24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LifeRadius.card)),
          child: Padding(
            padding: const EdgeInsets.all(LifeSpace.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Import ${preview.totalRows} rows?', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
                const SizedBox(height: LifeSpace.s12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final table in sortedTables)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '${_label(table)}: ${preview.countsByTable[table]}',
                              style: context.textStyles.callout.copyWith(color: colors.neutrals.ink2),
                            ),
                          ),
                        if (preview.unknownTables.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: LifeSpace.s8),
                            child: Text(
                              "Skipping ${preview.unknownTables.length} table(s) this version of Life OS doesn't recognise.",
                              style: context.textStyles.caption.copyWith(color: colors.neutrals.ink3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: LifeSpace.s20),
                Row(
                  children: [
                    Expanded(
                      child: LButton(
                        label: 'Cancel',
                        variant: LButtonVariant.plain,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: LifeSpace.s8),
                    Expanded(child: LButton(label: 'Import', onPressed: () => Navigator.of(context).pop(true))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  static String _label(String tableName) {
    final words = tableName.split('_');
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
