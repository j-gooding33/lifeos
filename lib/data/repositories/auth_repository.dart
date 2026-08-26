import 'package:life_os/core/errors/failure.dart';
import 'package:life_os/core/utils/result.dart';
import 'package:life_os/data/remote/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// §25 auth (email, Apple, Google) via Supabase. Every method fails with
/// an [AuthFailure] if [isSupabaseConfigured] is false — there is no
/// Supabase project on this machine yet, so none of this has been run
/// against a live backend (M4's own DoD requires that). See DECISIONS.md.
class AuthRepository {
  AuthRepository();

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  User? get currentUser => isSupabaseConfigured ? supabase.auth.currentUser : null;

  Future<Result<User, Failure>> signUpWithEmail(String email, String password) async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      final user = response.user;
      if (user == null) return const Err(AuthFailure('Sign up returned no user'));
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  Future<Result<User, Failure>> signInWithEmail(String email, String password) async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) return const Err(AuthFailure('Sign in returned no user'));
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  Future<Result<void, Failure>> signInWithApple() async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.apple);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  Future<Result<void, Failure>> signInWithGoogle() async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  Future<Result<void, Failure>> resetPassword(String email) async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }

  Future<Result<void, Failure>> signOut() async {
    if (!isSupabaseConfigured) return const Err(AuthFailure('Supabase is not configured'));
    try {
      await supabase.auth.signOut();
      return const Ok(null);
    } on AuthException catch (e) {
      return Err(AuthFailure(e.message));
    }
  }
}
