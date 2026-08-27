import 'package:life_os/data/local/daos/preferences_dao.dart';
import 'package:life_os/data/local/daos/profile_dao.dart';
import 'package:life_os/data/local/database.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';
import 'package:life_os/data/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_providers.g.dart';

/// Opened once for the app's lifetime (§31 bootstrap: "db open"). Tests
/// construct their own `AppDatabase.forTesting(...)` instead of overriding
/// this provider, since Drift's in-memory executor needs to be created
/// per test anyway.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ProfileDao(ref.watch(appDatabaseProvider)));
}

@Riverpod(keepAlive: true)
PreferencesRepository preferencesRepository(Ref ref) {
  return PreferencesRepository(PreferencesDao(ref.watch(appDatabaseProvider)));
}

/// §4 M4: local-first identity. Every feature that needs "the current
/// user" depends on this rather than auth state directly, since the app
/// must work before any sign-in exists.
@Riverpod(keepAlive: true)
Future<String> currentUserId(Ref ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.ensureLocalIdentity();
  return result.when(
    ok: (profile) => profile.id,
    err: (failure) => throw StateError('ensureLocalIdentity failed: ${failure.message}'),
  );
}
