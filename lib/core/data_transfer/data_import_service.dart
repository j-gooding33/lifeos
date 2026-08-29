import 'package:flutter/foundation.dart';
import 'package:life_os/data/local/database.dart';

/// Per-table row counts from an export file, shown to the user before
/// anything is written — §27.5's "dry-run preview showing counts."
class ImportPreview {
  ImportPreview({required this.countsByTable, required this.unknownTables});

  final Map<String, int> countsByTable;

  /// Table names present in the file that don't exist in this schema —
  /// surfaced rather than silently dropped, since it's the honest signal
  /// that the file is from a newer/older/foreign export.
  final List<String> unknownTables;

  int get totalRows => countsByTable.values.fold(0, (sum, count) => sum + count);
}

/// §27.5. Additive only — every insert is `INSERT OR IGNORE`, so a row
/// whose primary key already exists (re-importing the same backup twice)
/// is left untouched rather than overwritten or duplicated. Every row's
/// `user_id` column, if it has one, is rewritten to the importing
/// device's own local identity (§4) rather than kept as-is: an export's
/// `user_id` belongs to whichever device produced it, and every query in
/// this app filters on the current device's `currentUserId` — importing
/// without remapping would write rows nothing ever queries.
class DataImportService {
  DataImportService(this._db);

  final AppDatabase _db;

  static final _safeIdentifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

  ImportPreview preview(Map<String, Object?> export) {
    final tableNames = {for (final t in _db.allTables) t.actualTableName};
    final tables = _tablesOf(export);
    final counts = <String, int>{};
    final unknown = <String>[];
    for (final entry in tables.entries) {
      final rows = entry.value;
      if (rows.isEmpty) continue;
      if (!tableNames.contains(entry.key)) {
        unknown.add(entry.key);
        continue;
      }
      counts[entry.key] = rows.length;
    }
    return ImportPreview(countsByTable: counts, unknownTables: unknown);
  }

  /// Returns the number of tables that had at least one row attempted.
  /// Foreign keys are declared and enforced (`PRAGMA foreign_keys = ON`,
  /// see `database.dart`) but a plain per-table `SELECT *`/re-insert
  /// doesn't guarantee parent-before-child ordering survives a JSON
  /// round-trip, so FK checks are suspended for the duration of the
  /// import rather than relying on that ordering.
  Future<int> import(Map<String, Object?> export, {required String currentUserId}) async {
    final tableNames = {for (final t in _db.allTables) t.actualTableName};
    final tables = _tablesOf(export);
    var tablesTouched = 0;
    await _db.customStatement('PRAGMA foreign_keys = OFF;');
    try {
      for (final entry in tables.entries) {
        if (!tableNames.contains(entry.key) || entry.value.isEmpty) continue;
        for (final row in entry.value) {
          await _insertRow(entry.key, row, currentUserId);
        }
        tablesTouched++;
      }
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON;');
    }
    return tablesTouched;
  }

  Map<String, List<Map<String, Object?>>> _tablesOf(Map<String, Object?> export) {
    final raw = export['tables'];
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        if (entry.value is List)
          entry.key as String: (entry.value as List).whereType<Map<dynamic, dynamic>>().map(Map<String, Object?>.from).toList(),
    };
  }

  Future<void> _insertRow(String table, Map<String, Object?> row, String currentUserId) async {
    final columns = <String>[];
    final values = <Object?>[];
    for (final entry in row.entries) {
      // A column name that doesn't look like a real identifier can't be
      // safely interpolated into the SQL text below (identifiers, unlike
      // values, can't go through a `?` placeholder) — skip it rather
      // than trust a file that could have been hand-edited or corrupted
      // between export and import.
      if (!_safeIdentifier.hasMatch(entry.key)) continue;
      columns.add(entry.key);
      values.add(entry.key == 'user_id' ? currentUserId : entry.value);
    }
    if (columns.isEmpty) return;
    final columnList = columns.map((c) => '"$c"').join(', ');
    final placeholders = List.filled(columns.length, '?').join(', ');
    try {
      await _db.customStatement('INSERT OR IGNORE INTO "$table" ($columnList) VALUES ($placeholders)', values);
    } on Object catch (e) {
      // One malformed row (an unexpected column from a foreign/future
      // export, a type mismatch) shouldn't abort the rest of the import.
      debugPrint('Skipped a row importing into $table: $e');
    }
  }
}
