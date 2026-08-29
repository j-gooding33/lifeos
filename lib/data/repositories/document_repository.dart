import 'dart:io';

import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/document_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_document.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const maxDocumentBytes = 25 * 1024 * 1024;

/// §17.3. Files live in this app's own `documents/` folder — copied in at
/// import time, so the original the user picked from can be moved or
/// deleted afterwards without breaking anything here. "Uploaded to the
/// user's storage bucket on sync" isn't built — no sync backend exists yet;
/// see DECISIONS.md.
class DocumentRepository {
  DocumentRepository(this._dao);

  final DocumentDao _dao;

  Stream<List<AppDocument>> watchAll(String userId) => _dao.watchAll(userId).map(_toDomainList);

  Future<int> totalSizeBytes(String userId) => _dao.totalSizeBytes(userId);

  /// [sourcePath] is wherever the platform file picker left the picked
  /// file — read once, here, and never touched again afterwards.
  Future<Result<AppDocument, Failure>> import({
    required String userId,
    required String sourcePath,
    required String originalName,
    required int fileSizeBytes,
    String? mimeType,
  }) async {
    if (fileSizeBytes > maxDocumentBytes) {
      return Err(DocumentTooLargeFailure(fileSizeBytes, maxDocumentBytes));
    }
    try {
      final directory = await _documentsDirectory();
      final storedName = '${const Uuid().v4()}${p.extension(originalName)}';
      await File(sourcePath).copy(p.join(directory.path, storedName));

      final document = AppDocument(
        id: const Uuid().v4(),
        userId: userId,
        title: originalName,
        storedName: storedName,
        originalName: originalName,
        fileSizeBytes: fileSizeBytes,
        mimeType: mimeType,
      );
      await _save(document);
      return Ok(document);
    } on Object catch (e) {
      return Err(DatabaseFailure('import failed: $e'));
    }
  }

  Future<Result<void, Failure>> rename(AppDocument document, String title) async {
    try {
      await _save(document.copyWith(title: title));
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('rename failed: $e'));
    }
  }

  Future<Result<void, Failure>> delete(AppDocument document) async {
    try {
      await _dao.softDelete(document.id, DateTime.now().millisecondsSinceEpoch);
      final directory = await _documentsDirectory();
      final file = File(p.join(directory.path, document.storedName));
      if (file.existsSync()) await file.delete();
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('delete failed: $e'));
    }
  }

  Future<File> fileFor(AppDocument document) async {
    final directory = await _documentsDirectory();
    return File(p.join(directory.path, document.storedName));
  }

  Future<Directory> _documentsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'documents'));
    if (!directory.existsSync()) await directory.create(recursive: true);
    return directory;
  }

  Future<void> _save(AppDocument document) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsert(
      db.DocumentsCompanion(
        id: Value(document.id),
        userId: Value(document.userId),
        title: Value(document.title),
        storedName: Value(document.storedName),
        originalName: Value(document.originalName),
        fileSizeBytes: Value(document.fileSizeBytes),
        mimeType: Value(document.mimeType),
        createdAt: Value(document.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(now),
      ),
    );
  }

  List<AppDocument> _toDomainList(List<db.Document> rows) => rows.map(_toDomain).toList();

  AppDocument _toDomain(db.Document row) {
    return AppDocument(
      id: row.id,
      userId: row.userId,
      title: row.title,
      storedName: row.storedName,
      originalName: row.originalName,
      fileSizeBytes: row.fileSizeBytes,
      mimeType: row.mimeType,
      createdAt: row.createdAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.createdAt!),
      updatedAt: row.updatedAt == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(row.updatedAt!),
    );
  }
}
