import 'package:drift/drift.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/local/daos/profile_dao.dart';
import 'package:life_os/data/local/database.dart' as db;
import 'package:life_os/data/repositories/models/app_profile.dart';
import 'package:uuid/uuid.dart';

class ProfileRepository {
  ProfileRepository(this._dao);

  final ProfileDao _dao;

  Stream<AppProfile?> watchProfile(String userId) {
    return _dao.watchProfile(userId).map(_toDomain);
  }

  /// §4 M4: the app must be usable before any sign-in. Returns the
  /// device's local profile, creating one with a fresh client-generated id
  /// if this is the first launch. Sync (M19) is what later reconciles this
  /// id with a real Supabase user, not this method.
  Future<Result<AppProfile, Failure>> ensureLocalIdentity() async {
    try {
      final existing = await _dao.getAnyProfile();
      if (existing != null) return Ok(_toDomain(existing)!);

      final profile = AppProfile(id: const Uuid().v4());
      final saveResult = await saveProfile(profile);
      return saveResult.when<Result<AppProfile, Failure>>(
        ok: (_) => Ok(profile),
        err: Err<AppProfile, Failure>.new,
      );
    } on Object catch (e) {
      return Err(DatabaseFailure('ensureLocalIdentity failed: $e'));
    }
  }

  Future<Result<AppProfile?, Failure>> getProfile(String userId) async {
    try {
      return Ok(_toDomain(await _dao.getProfile(userId)));
    } on Object catch (e) {
      return Err(DatabaseFailure('getProfile failed: $e'));
    }
  }

  Future<Result<void, Failure>> saveProfile(AppProfile profile) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _dao.upsertProfile(
        db.ProfilesCompanion(
          id: Value(profile.id),
          displayName: Value(profile.displayName),
          avatarPath: Value(profile.avatarPath),
          timezone: Value(profile.timezone),
          weekStart: Value(profile.weekStart),
          currency: Value(profile.currency),
          dateFormat: Value(profile.dateFormat),
          onboardedAt: Value(profile.onboardedAt?.millisecondsSinceEpoch),
          updatedAt: Value(now),
        ),
      );
      return const Ok(null);
    } on Object catch (e) {
      return Err(DatabaseFailure('saveProfile failed: $e'));
    }
  }

  AppProfile? _toDomain(db.Profile? row) {
    if (row == null) return null;
    return AppProfile(
      id: row.id,
      displayName: row.displayName,
      avatarPath: row.avatarPath,
      timezone: row.timezone,
      weekStart: row.weekStart,
      currency: row.currency,
      dateFormat: row.dateFormat,
      onboardedAt: row.onboardedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.onboardedAt!),
    );
  }
}
