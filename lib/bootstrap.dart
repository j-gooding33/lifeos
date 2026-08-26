import 'dart:async';

import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(flavor);
  await initializeSupabase();

  if (_sentryDsn.isEmpty) {
    runZonedGuarded(
      () => runApp(const LifeOsApp()),
      (error, stack) => debugPrint('Uncaught error: $error\n$stack'),
    );
    return;
  }

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = _sentryDsn
        ..environment = flavor.name;
    },
    appRunner: () => runApp(const LifeOsApp()),
  );
}
