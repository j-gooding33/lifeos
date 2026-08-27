import 'dart:convert';

import 'package:life_os/data/repositories/models/onboarding_answer.dart';
import 'package:life_os/data/repositories/preferences_repository.dart';

const _hasOnboardedKey = 'hasOnboarded';
const _answersKey = 'onboardingAnswers';

/// First-run state (item 8) — stored through the existing key/value
/// `Preferences` table (same pattern as the theme scheme, see
/// DECISIONS.md), not a dedicated table: a one-time, low-volume blob
/// doesn't earn its own schema migration.
class OnboardingRepository {
  OnboardingRepository(this._preferences);

  final PreferencesRepository _preferences;

  Stream<bool> watchHasOnboarded(String userId) {
    return _preferences.watch(userId, _hasOnboardedKey).map((v) => v == 'true');
  }

  Future<void> setHasOnboarded(String userId, {required bool value}) {
    return _preferences.set(userId, _hasOnboardedKey, value.toString());
  }

  Future<List<OnboardingAnswer>> getAnswers(String userId) async {
    final result = await _preferences.get(userId, _answersKey);
    final raw = result.when(ok: (v) => v, err: (_) => null);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => OnboardingAnswer.fromJson(e as Map<String, Object?>)).toList();
  }

  Future<void> saveAnswers(String userId, List<OnboardingAnswer> answers) {
    return _preferences.set(userId, _answersKey, jsonEncode(answers.map((a) => a.toJson()).toList()));
  }
}
