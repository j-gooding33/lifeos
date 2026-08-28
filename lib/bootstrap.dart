import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/app.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/data/remote/supabase_client.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// The Sentry DSN is never hard-coded. It is supplied per build via
/// `--dart-define=SENTRY_DSN=...` (from an Edge Function-issued value at
/// release time, not committed to the repo). An empty DSN keeps crash
/// reporting off, which is the default for every local/dev build.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> bootstrap(Flavor flavor) async {
  // §M1: `WidgetsFlutterBinding.ensureInitialized()` must run in the same
  // zone as `runApp` — calling it before `runZonedGuarded` (as this used
  // to) throws a "Zone mismatch" assertion on every run, since `runApp`
  // then executes in a *different* zone than the binding was initialised
  // in. Both branches below now initialise everything inside the zone
  // `runApp` itself runs in.
  if (_sentryDsn.isEmpty) {
    unawaited(runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        AppConfig.initialize(flavor);
        await initializeSupabase();
        runApp(const ProviderScope(child: LifeOsApp()));
      },
      (error, stack) => debugPrint('Uncaught error: $error\n$stack'),
    ));
    return;
  }

  // `SentryFlutter.init` wraps `appRunner` in its own zone (for automatic
  // error capture), so the same rule applies: the binding is initialised
  // inside `appRunner`, not before this call.
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = _sentryDsn
        ..environment = flavor.name;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppConfig.initialize(flavor);
      await initializeSupabase();
      runApp(const ProviderScope(child: LifeOsApp()));
    },
  );
}
