import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/data_transfer/data_export_service.dart';
import 'package:life_os/core/data_transfer/data_import_service.dart';
import 'package:life_os/core/scheduling/civil_date.dart';
import 'package:life_os/data/local/daos/task_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/task_repository.dart';

void main() {
  late AppDatabase source;
  late AppDatabase destination;

  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    destination = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await source.close();
    await destination.close();
  });

  test('a preview counts rows per table without writing anything', () async {
    final taskRepository = TaskRepository(TaskDao(source));
    await taskRepository.createTask(userId: 'device-a', title: 'Water plants');
    await taskRepository.createTask(userId: 'device-a', title: 'Call dentist');

    final export = await DataExportService(source).buildExport();
    final preview = DataImportService(destination).preview(export);

    expect(preview.countsByTable['tasks'], 2);
    expect(preview.totalRows, greaterThanOrEqualTo(2));
    expect(preview.unknownTables, isEmpty);
    final destinationTasks = await TaskRepository(TaskDao(destination)).watchAllDueOn('device-a', CivilDate.fromDateTime(DateTime.now())).first;
    expect(destinationTasks, isEmpty, reason: 'preview must not write');
  });

  test('importing writes rows and remaps user_id to the importing device', () async {
    final taskRepository = TaskRepository(TaskDao(source));
    await taskRepository.createTask(userId: 'device-a', title: 'Water plants', dueDate: CivilDate.fromDateTime(DateTime.now()).toIso());

    final export = await DataExportService(source).buildExport();
    await DataImportService(destination).import(export, currentUserId: 'device-b');

    final imported = await TaskRepository(TaskDao(destination)).watchAllDueOn('device-b', CivilDate.fromDateTime(DateTime.now())).first;
    expect(imported, hasLength(1));
    expect(imported.single.title, 'Water plants');
    expect(imported.single.userId, 'device-b');
  });

  test('a subtask survives the round-trip alongside its parent task (foreign keys enforced)', () async {
    final taskRepository = TaskRepository(TaskDao(source));
    final created = await taskRepository.createTask(userId: 'device-a', title: 'Plan trip');
    final task = created.when(ok: (t) => t, err: (f) => throw StateError(f.message));
    await taskRepository.addSubtask(task.id, 'Book flights');

    final export = await DataExportService(source).buildExport();
    await DataImportService(destination).import(export, currentUserId: 'device-b');

    final subtasks = await TaskRepository(TaskDao(destination)).watchSubtasks(task.id).first;
    expect(subtasks, hasLength(1));
    expect(subtasks.single.title, 'Book flights');
  });

  test('importing the same export twice does not duplicate rows', () async {
    final taskRepository = TaskRepository(TaskDao(source));
    await taskRepository.createTask(userId: 'device-a', title: 'Water plants', dueDate: CivilDate.fromDateTime(DateTime.now()).toIso());
    final export = await DataExportService(source).buildExport();

    final importService = DataImportService(destination);
    await importService.import(export, currentUserId: 'device-b');
    await importService.import(export, currentUserId: 'device-b');

    final imported = await TaskRepository(TaskDao(destination)).watchAllDueOn('device-b', CivilDate.fromDateTime(DateTime.now())).first;
    expect(imported, hasLength(1));
  });

  test('excluded tables (sync bookkeeping, caches) never appear in the export', () async {
    final export = await DataExportService(source).buildExport();
    final tables = (export['tables']! as Map<String, Object?>).keys.toSet();
    for (final excluded in DataExportService.excludedTables) {
      expect(tables.contains(excluded), isFalse, reason: '$excluded should be excluded');
    }
  });

  test('a table name from an unknown/future schema is reported, not silently dropped', () {
    final export = <String, Object?>{
      'schemaVersion': 999,
      'tables': {
        'tasks': <Map<String, Object?>>[],
        'a_table_from_the_future': [
          {'id': '1'},
        ],
      },
    };
    final preview = DataImportService(destination).preview(export);
    expect(preview.unknownTables, ['a_table_from_the_future']);
  });
}
