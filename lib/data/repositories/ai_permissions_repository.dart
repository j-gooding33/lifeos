import 'dart:convert';

import 'package:life_os/data/repositories/models/ai_permission_scopes.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

const _scopesKey = 'aiPermissionScopes';

/// §19.2, M8 Parts 35-40. Stored through the existing key/value
/// `Preferences` table, same pattern as onboarding state and the theme
/// scheme (see DECISIONS.md) — a single low-volume blob doesn't earn its
/// own schema migration. Inert until a real AI backend exists to enforce
/// it (see the AI decision in DECISIONS.md); today this is only ever read
/// by Settings → AI.
class AiPermissionsRepository {
  AiPermissionsRepository(this._preferences);

  final PreferencesRepository _preferences;

  Stream<AiPermissionScopes> watch(String userId) {
    return _preferences.watch(userId, _scopesKey).map(_parse);
  }

  Future<void> save(String userId, AiPermissionScopes scopes) {
    return _preferences.set(userId, _scopesKey, jsonEncode(scopes.toJson()));
  }

  AiPermissionScopes _parse(String? raw) {
    if (raw == null || raw.isEmpty) return const AiPermissionScopes();
    return AiPermissionScopes.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }
}
