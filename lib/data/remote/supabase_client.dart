import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// §25, rule 7 (secrets never ship in the app). The URL and anon key are
/// supplied per build via `--dart-define`, the same pattern as Sentry's
/// DSN in `bootstrap.dart` — the anon key is the one secret the spec
/// explicitly allows to ship, because it's only safe when RLS is correct
/// (rule 7), not because it's exempt from this pattern.
///
/// Until a real Supabase project exists, both defines are empty and
/// [initializeSupabase] is a no-op — every auth call fails clearly rather
/// than pretending to work. See DECISIONS.md.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

bool get isSupabaseConfigured => _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

Future<void> initializeSupabase() async {
  if (!isSupabaseConfigured) return;
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
    // §4 M4 DoD: session must survive an app kill. supabase_flutter's
    // default local storage is SharedPreferences, which isn't
    // platform-secure storage — the refresh token goes in the Keychain
    // / Keystore instead (CLAUDE.md conventions: secure storage for the
    // refresh token only).
    authOptions: const FlutterAuthClientOptions(localStorage: _SecureSessionStorage()),
  );
}

SupabaseClient get supabase => Supabase.instance.client;

class _SecureSessionStorage extends LocalStorage {
  const _SecureSessionStorage();

  static const _storage = FlutterSecureStorage();
  static const _key = 'supabase.session';

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() async => (await _storage.read(key: _key)) != null;

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}
