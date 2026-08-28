import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preference_toggle.g.dart';

/// A boolean setting backed by the key/value `Preferences` table, for the
/// many independent on/off switches Settings needs (Notifications'
/// categories, Privacy's opt-outs) without a schema change per switch.
/// Unset reads as `false` — every toggle here defaults off.
@riverpod
Stream<bool> boolPreference(Ref ref, String key) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(preferencesRepositoryProvider).watch(userId, key).map((v) => v == 'true');
}

Future<void> setBoolPreference(WidgetRef ref, String key, {required bool value}) async {
  final userId = await ref.read(currentUserIdProvider.future);
  await ref.read(preferencesRepositoryProvider).set(userId, key, value.toString());
}

@riverpod
Stream<String?> stringPreference(Ref ref, String key) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(preferencesRepositoryProvider).watch(userId, key);
}

Future<void> setStringPreference(WidgetRef ref, String key, String value) async {
  final userId = await ref.read(currentUserIdProvider.future);
  await ref.read(preferencesRepositoryProvider).set(userId, key, value);
}
