import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/preferences_dao.dart';

/// Key/value settings (§23.3) — avoids a schema migration per setting, so
/// the repository is intentionally untyped at this layer. Callers define
/// their own typed wrappers (e.g. a `reduceMotion` bool getter) on top.
class PreferencesRepository {
  PreferencesRepository(this._dao);

  final PreferencesDao _dao;

  Stream<String?> watch(String userId, String key) => _dao.watchValue(userId, key);

  Future<Result<String?, Failure>> get(String userId, String key) async {
    try {
      return Ok(await _dao.getValue(userId, key));
    } on Object catch (e) {
      return Err(DatabaseFailure('preferences get failed: $e'));
    }
  }

  Future<Result<void, Failure>> set(String userId, String key, String value) async {
    try {
      await _dao.setValue(userId, key, value);
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('preferences set failed: $e'));
    }
  }
}
