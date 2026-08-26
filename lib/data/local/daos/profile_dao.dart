import 'package:drift/drift.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/local/tables/profiles_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<Profile?> watchProfile(String id) =>
      (select(profiles)..where((p) => p.id.equals(id))).watchSingleOrNull();

  Future<Profile?> getProfile(String id) =>
      (select(profiles)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Local-first identity (§4 M4): before any cloud sign-in there's at
  /// most one profile row on the device, so "is there a local identity
  /// yet" is just "does any row exist."
  Future<Profile?> getAnyProfile() => (select(profiles)..limit(1)).getSingleOrNull();

  Future<void> upsertProfile(ProfilesCompanion entry) =>
      into(profiles).insertOnConflictUpdate(entry);
}
