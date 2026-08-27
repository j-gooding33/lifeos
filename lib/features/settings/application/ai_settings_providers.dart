import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/core/providers/app_providers.dart';
import 'package:life_os/data/repositories/ai_permissions_repository.dart';
import 'package:life_os/data/repositories/models/ai_permission_scopes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_settings_providers.g.dart';

@Riverpod(keepAlive: true)
AiPermissionsRepository aiPermissionsRepository(Ref ref) {
  return AiPermissionsRepository(ref.watch(preferencesRepositoryProvider));
}

@riverpod
Stream<AiPermissionScopes> aiPermissionScopes(Ref ref) async* {
  final userId = await ref.watch(currentUserIdProvider.future);
  yield* ref.watch(aiPermissionsRepositoryProvider).watch(userId);
}

Future<void> saveAiPermissionScopes(WidgetRef ref, AiPermissionScopes scopes) async {
  final userId = await ref.read(currentUserIdProvider.future);
  await ref.read(aiPermissionsRepositoryProvider).save(userId, scopes);
}
