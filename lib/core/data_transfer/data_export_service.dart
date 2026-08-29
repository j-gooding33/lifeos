import 'dart:convert';
import 'dart:io';

import 'package:life_os/data/local/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// §27.5. A JSON-only v1: every table gets a generic `SELECT *`, dumped
/// as-is via Drift's own `QueryRow.data` rather than 37 hand-written
/// per-entity serializers — full column fidelity for free, and every
/// table added to the schema later is included automatically. What the
/// spec's ZIP additionally bundles — a `data.csv` spreadsheet export and
/// attachments — isn't built; see DECISIONS.md.
class DataExportService {
  DataExportService(this._db);

  final AppDatabase _db;

  /// Rows here either aren't user data (`sync_state`, `outbox`,
  /// `media_metadata_cache` is a re-fetchable TMDB/Open Library cache,
  /// `daily_rollups` is unused) or are file-backed (`attachments`,
  /// `documents`) and out of scope for a JSON-only export.
  static const excludedTables = {'sync_state', 'outbox', 'media_metadata_cache', 'daily_rollups', 'attachments', 'documents'};

  Future<Map<String, Object?>> buildExport() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _db.allTables) {
      final name = table.actualTableName;
      if (excludedTables.contains(name)) continue;
      final rows = await _db.customSelect('SELECT * FROM "$name"').get();
      tables[name] = [for (final row in rows) Map<String, Object?>.from(row.data)];
    }
    return {'schemaVersion': _db.schemaVersion, 'exportedAt': DateTime.now().toIso8601String(), 'tables': tables};
  }

  Future<File> writeExportFile() async {
    final export = await buildExport();
    final json = const JsonEncoder.withIndent('  ').convert(export);
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp('[:.]'), '-');
    final file = File(p.join((await getTemporaryDirectory()).path, 'life_os_export_$timestamp.json'));
    await file.writeAsString(json);
    return file;
  }

  Future<void> shareExport() async {
    final file = await writeExportFile();
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Life OS data export'));
  }
}
