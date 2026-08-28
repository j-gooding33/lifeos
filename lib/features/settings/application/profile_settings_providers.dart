import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/models/app_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_settings_providers.g.dart';

@riverpod
Stream<AppProfile?> currentProfile(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(profileRepositoryProvider).watchProfile(userId);
}

Future<void> saveProfile(WidgetRef ref, AppProfile profile) async {
  await ref.read(profileRepositoryProvider).saveProfile(profile);
}
