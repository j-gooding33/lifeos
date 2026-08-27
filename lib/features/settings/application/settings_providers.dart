import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/design/tokens/theme_scheme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Stored as plain text in the existing key/value `Preferences` table
/// (`preferences_repository.dart`'s own doc comment invites exactly this:
/// "callers define their own typed wrappers on top") — no schema change
/// needed for a single setting.
const _themeSchemeKey = 'themeScheme';

LifeThemeScheme _parseThemeScheme(String? value) {
  for (final scheme in LifeThemeScheme.values) {
    if (scheme.name == value) return scheme;
  }
  return LifeThemeScheme.afterHours;
}

@riverpod
Stream<LifeThemeScheme> currentThemeScheme(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(preferencesRepositoryProvider).watch(userId, _themeSchemeKey).map(_parseThemeScheme);
}

Future<void> setThemeScheme(WidgetRef ref, LifeThemeScheme scheme) async {
  final userId = await ref.read(currentUserIdProvider.future);
  await ref.read(preferencesRepositoryProvider).set(userId, _themeSchemeKey, scheme.name);
}
