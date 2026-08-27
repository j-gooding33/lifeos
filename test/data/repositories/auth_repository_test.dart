import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/data/repositories/auth_repository.dart';

/// This machine has no Supabase project, so `isSupabaseConfigured` is
/// false and every real auth call is untestable here — see DECISIONS.md.
/// What *is* testable, and matters: every method must fail clearly with
/// an [AuthFailure] rather than crash or silently no-op when
/// unconfigured, since that's the state every dev/CI run is in today.
void main() {
  final repository = AuthRepository();

  test('currentUser is null when unconfigured', () {
    expect(repository.currentUser, isNull);
  });

  test('signInWithEmail fails clearly when unconfigured', () async {
    final result = await repository.signInWithEmail(
      'a@example.com',
      'password',
    );
    result.when(
      ok: (_) => fail('expected Err'),
      err: (failure) => expect(failure, isA<AuthFailure>()),
    );
  });

  test('signUpWithEmail fails clearly when unconfigured', () async {
    final result = await repository.signUpWithEmail(
      'a@example.com',
      'password',
    );
    result.when(
      ok: (_) => fail('expected Err'),
      err: (failure) => expect(failure, isA<AuthFailure>()),
    );
  });

  test('signOut fails clearly when unconfigured', () async {
    final result = await repository.signOut();
    result.when(
      ok: (_) => fail('expected Err'),
      err: (failure) => expect(failure, isA<AuthFailure>()),
    );
  });
}
