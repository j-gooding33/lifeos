import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/core/utils/byte_format.dart';
import 'package:life_os/data/local/daos/document_dao.dart';
import 'package:life_os/data/repositories/document_repository.dart';
import 'package:life_os/data/repositories/models/app_document.dart';
import 'package:life_os/design/components/l_list_tile.dart';
import 'package:life_os/design/components/l_section_header.dart';
import 'package:life_os/design/components/l_toast.dart';
import 'package:life_os/design/theme/theme_extensions.dart';
import 'package:life_os/design/tokens/spacing.dart';
import 'package:open_filex/open_filex.dart';

/// §11.3, §17.3. Lives in `design/components` (not the Library feature)
/// for the same CLAUDE.md rule 4 reason `LNotesSection` does — every
/// feature's detail screen needs a Files section, so it constructs its
/// own [DocumentRepository] straight from the DAO rather than importing
/// Library's own provider file.
final _documentsRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(DocumentDao(ref.watch(appDatabaseProvider)));
});

final _linkedDocumentsProvider = StreamProvider.family<List<AppDocument>, (String, String)>((ref, args) {
  return ref.watch(_documentsRepositoryProvider).watchLinkedTo(args.$1, args.$2);
});

IconData _iconFor(AppDocument document) {
  final extension = document.originalName.split('.').last.toLowerCase();
  return switch (extension) {
    'pdf' => Icons.picture_as_pdf_outlined,
    'jpg' || 'jpeg' || 'png' || 'heic' || 'gif' => Icons.image_outlined,
    'doc' || 'docx' => Icons.description_outlined,
    'xls' || 'xlsx' || 'csv' => Icons.table_chart_outlined,
    _ => Icons.insert_drive_file_outlined,
  };
}

class LFilesSection extends ConsumerWidget {
  const LFilesSection({required this.entityType, required this.entityId, super.key});

  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final asyncDocuments = ref.watch(_linkedDocumentsProvider((entityType, entityId)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LSectionHeader(
          title: 'Files',
          trailing: IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Add a file',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showPicker(context, ref),
          ),
        ),
        const SizedBox(height: LifeSpace.s8),
        asyncDocuments.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
          data: (documents) {
            if (documents.isEmpty) {
              return Text('No files linked yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2));
            }
            return Column(
              children: [
                for (final document in documents)
                  LListTile(
                    leading: Icon(_iconFor(document)),
                    title: document.title,
                    subtitle: formatBytes(document.fileSizeBytes),
                    trailing: IconButton(
                      icon: const Icon(Icons.link_off, size: 18),
                      tooltip: 'Unlink',
                      onPressed: () =>
                          ref.read(_documentsRepositoryProvider).unlinkDocument(documentId: document.id, entityType: entityType, entityId: entityId),
                    ),
                    onTap: () => _open(context, ref, document),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, AppDocument document) async {
    final file = await ref.read(_documentsRepositoryProvider).fileFor(document);
    final result = await OpenFilex.open(file.path);
    if (!context.mounted || result.type == ResultType.done) return;
    final message = switch (result.type) {
      ResultType.noAppToOpen => 'No app on this device can open that file type.',
      ResultType.fileNotFound => "That file couldn't be found.",
      ResultType.permissionDenied => 'Permission denied opening that file.',
      _ => "Couldn't open that file.",
    };
    LToast.show(context, message);
  }

  Future<void> _showPicker(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(_documentsRepositoryProvider);
    final userId = await ref.read(currentUserIdProvider.future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _FilePickerSheet(repository: repository, userId: userId, entityType: entityType, entityId: entityId),
    );
  }
}

class _FilePickerSheet extends StatelessWidget {
  const _FilePickerSheet({required this.repository, required this.userId, required this.entityType, required this.entityId});

  final DocumentRepository repository;
  final String userId;
  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(LifeSpace.s16, LifeSpace.s16, LifeSpace.s16, LifeSpace.s8),
              child: Text('Link a file', style: context.textStyles.title3.copyWith(color: colors.neutrals.ink)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: LifeSpace.s8),
              child: TextButton.icon(
                onPressed: () => _importAndLink(context),
                icon: const Icon(Icons.add),
                label: const Text('Import a new file'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<AppDocument>>(
                stream: repository.watchAll(userId),
                builder: (context, snapshot) {
                  final documents = snapshot.data ?? const <AppDocument>[];
                  if (documents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(LifeSpace.s16),
                      child: Text('No documents yet.', style: context.textStyles.body.copyWith(color: colors.neutrals.ink2)),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return LListTile(
                        leading: Icon(_iconFor(document)),
                        title: document.title,
                        subtitle: formatBytes(document.fileSizeBytes),
                        onTap: () async {
                          await repository.linkDocument(documentId: document.id, entityType: entityType, entityId: entityId);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importAndLink(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    final picked = result?.files.single;
    if (picked?.path == null || !context.mounted) return;

    final imported = await repository.import(
      userId: userId,
      sourcePath: picked!.path!,
      originalName: picked.name,
      fileSizeBytes: picked.size,
    );
    if (!context.mounted) return;
    await imported.when(
      ok: (document) async {
        await repository.linkDocument(documentId: document.id, entityType: entityType, entityId: entityId);
        if (context.mounted) Navigator.of(context).pop();
      },
      err: (failure) async => LToast.show(context, failure.message),
    );
  }
}
