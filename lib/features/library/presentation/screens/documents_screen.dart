import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/utils/byte_format.dart';
import 'package:life_os/data/repositories/models/app_document.dart';
import 'package:life_os/design/components/l_confirm_dialog.dart';
import 'package:life_os/design/components/l_empty_state.dart';
import 'package:life_os/design/components/l_error_state.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_prompt_dialog.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/features/library/application/document_providers.dart';

/// §17.3. Files are copied into this app's own local storage at import
/// time and capped at 25MB each. Opening a document in-place (needs a
/// FileProvider/`open_filex`-style native viewer hookup) and "uploaded to
/// the user's storage bucket on sync" (no sync backend yet) aren't built —
/// see DECISIONS.md.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncDocuments = ref.watch(allDocumentsProvider);

    return Scaffold(
      backgroundColor: colors.neutrals.bg,
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: 'Import a file', onPressed: () => _import(context, ref)),
        ],
      ),
      body: asyncDocuments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            LErrorState(message: "Couldn't load your documents.", onRetry: () => ref.invalidate(allDocumentsProvider)),
        data: (documents) {
          if (documents.isEmpty) {
            return LEmptyState(
              icon: Icons.insert_drive_file_outlined,
              title: 'No documents yet',
              message: 'Import a file with the + button. Up to 25MB each, stored on this device.',
              actionLabel: 'Import a file',
              onAction: () => _import(context, ref),
            );
          }
          return ListView.separated(
            itemCount: documents.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _DocumentRow(document: documents[index]),
          );
        },
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    final picked = result?.files.single;
    if (picked?.path == null || !context.mounted) return;

    final userId = await ref.read(currentUserIdProvider.future);
    final imported = await ref
        .read(documentRepositoryProvider)
        .import(userId: userId, sourcePath: picked!.path!, originalName: picked.name, fileSizeBytes: picked.size);
    if (!context.mounted) return;
    imported.when(ok: (_) {}, err: (f) => LToast.show(context, f.message));
  }
}

class _DocumentRow extends ConsumerWidget {
  const _DocumentRow({required this.document});

  final AppDocument document;

  IconData get _icon {
    final extension = document.originalName.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'jpg' || 'jpeg' || 'png' || 'heic' || 'gif' => Icons.image_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      'xls' || 'xlsx' || 'csv' => Icons.table_chart_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LListTile(
      leading: Icon(_icon),
      title: document.title,
      subtitle: formatBytes(document.fileSizeBytes),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Rename',
            onPressed: () => _rename(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final title = await LPromptDialog.show(context, title: 'Rename', label: 'Title', initialValue: document.title);
    if (title == null || title.isEmpty) return;
    await ref.read(documentRepositoryProvider).rename(document, title);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await LConfirmDialog.show(context, title: 'Delete this document?', message: 'This cannot be undone.');
    if (confirmed) {
      await ref.read(documentRepositoryProvider).delete(document);
    }
  }
}
