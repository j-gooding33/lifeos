import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/data/local/daos/document_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/document_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  _FakePathProvider(this.directoryPath);

  final String directoryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => directoryPath;

  @override
  Future<String?> getTemporaryPath() async => directoryPath;
}

void main() {
  late Directory tempDir;
  late AppDatabase database;
  late DocumentRepository repository;
  late File sourceFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('life_os_documents_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DocumentRepository(DocumentDao(database));
    sourceFile = File(p.join(tempDir.path, 'source.txt'))..writeAsStringSync('hello world');
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('import copies the file into local storage and records its metadata', () async {
    final result = await repository.import(
      userId: 'u1',
      sourcePath: sourceFile.path,
      originalName: 'notes.txt',
      fileSizeBytes: sourceFile.lengthSync(),
    );
    final document = result.when(ok: (d) => d, err: (f) => throw StateError(f.message));

    expect(document.title, 'notes.txt');
    final storedFile = await repository.fileFor(document);
    expect(storedFile.existsSync(), isTrue);
    expect(storedFile.readAsStringSync(), 'hello world');

    final all = await repository.watchAll('u1').first;
    expect(all.single.id, document.id);
  });

  test('rejects a file over the 25MB cap without touching disk', () async {
    final result = await repository.import(
      userId: 'u1',
      sourcePath: sourceFile.path,
      originalName: 'huge.bin',
      fileSizeBytes: maxDocumentBytes + 1,
    );
    expect(result.when(ok: (_) => null, err: (f) => f), isA<DocumentTooLargeFailure>());

    final all = await repository.watchAll('u1').first;
    expect(all, isEmpty);
  });

  test('delete removes both the row and the file on disk', () async {
    final imported = await repository.import(
      userId: 'u1',
      sourcePath: sourceFile.path,
      originalName: 'notes.txt',
      fileSizeBytes: sourceFile.lengthSync(),
    );
    final document = imported.when(ok: (d) => d, err: (f) => throw StateError(f.message));
    final storedFile = await repository.fileFor(document);
    expect(storedFile.existsSync(), isTrue);

    await repository.delete(document);

    expect(storedFile.existsSync(), isFalse);
    final all = await repository.watchAll('u1').first;
    expect(all, isEmpty);
  });

  test('totalSizeBytes sums every non-deleted document for that user', () async {
    await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'a.txt', fileSizeBytes: 100);
    await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'b.txt', fileSizeBytes: 250);
    await repository.import(userId: 'u2', sourcePath: sourceFile.path, originalName: 'c.txt', fileSizeBytes: 999);

    expect(await repository.totalSizeBytes('u1'), 350);
  });

  test('linkDocument makes the document appear in watchLinkedTo for that entity, and only that entity', () async {
    final imported = await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'a.txt', fileSizeBytes: 1);
    final document = imported.when(ok: (d) => d, err: (f) => throw StateError(f.message));

    await repository.linkDocument(documentId: document.id, entityType: 'project', entityId: 'p1');

    final linkedToProject = await repository.watchLinkedTo('project', 'p1').first;
    expect(linkedToProject.single.id, document.id);

    final linkedToOtherProject = await repository.watchLinkedTo('project', 'p2').first;
    expect(linkedToOtherProject, isEmpty);
  });

  test('the same document can be linked to more than one entity', () async {
    final imported = await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'a.txt', fileSizeBytes: 1);
    final document = imported.when(ok: (d) => d, err: (f) => throw StateError(f.message));

    await repository.linkDocument(documentId: document.id, entityType: 'project', entityId: 'p1');
    await repository.linkDocument(documentId: document.id, entityType: 'task', entityId: 't1');

    expect((await repository.watchLinkedTo('project', 'p1').first).single.id, document.id);
    expect((await repository.watchLinkedTo('task', 't1').first).single.id, document.id);
  });

  test('unlinkDocument removes just that one link', () async {
    final imported = await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'a.txt', fileSizeBytes: 1);
    final document = imported.when(ok: (d) => d, err: (f) => throw StateError(f.message));
    await repository.linkDocument(documentId: document.id, entityType: 'project', entityId: 'p1');
    await repository.linkDocument(documentId: document.id, entityType: 'task', entityId: 't1');

    await repository.unlinkDocument(documentId: document.id, entityType: 'project', entityId: 'p1');

    expect(await repository.watchLinkedTo('project', 'p1').first, isEmpty);
    expect((await repository.watchLinkedTo('task', 't1').first).single.id, document.id);
  });

  test('a deleted document drops out of watchLinkedTo even if the link row still exists', () async {
    final imported = await repository.import(userId: 'u1', sourcePath: sourceFile.path, originalName: 'a.txt', fileSizeBytes: 1);
    final document = imported.when(ok: (d) => d, err: (f) => throw StateError(f.message));
    await repository.linkDocument(documentId: document.id, entityType: 'project', entityId: 'p1');

    await repository.delete(document);

    expect(await repository.watchLinkedTo('project', 'p1').first, isEmpty);
  });
}
