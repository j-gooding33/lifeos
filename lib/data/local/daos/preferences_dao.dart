import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/preferences_table.dart';

part 'preferences_dao.g.dart';

@DriftAccessor(tables: [Preferences])
class PreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$PreferencesDaoMixin {
  PreferencesDao(super.db);

  Stream<String?> watchValue(String userId, String key) {
    final query = select(preferences)
      ..where((p) => p.userId.equals(userId) & p.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<String?> getValue(String userId, String key) async {
    final query = select(preferences)
      ..where((p) => p.userId.equals(userId) & p.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String userId, String key, String value) {
    return into(preferences).insertOnConflictUpdate(
      PreferencesCompanion.insert(
        userId: userId,
        key: key,
        value: Value(value),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
