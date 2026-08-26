import 'package:flutter/material.dart';
import 'package:life_os/core/config/flavor.dart';
import 'package:life_os/design/theme/dark_theme.dart';
import 'package:life_os/design/theme/light_theme.dart';
import 'package:life_os/design/theme/scaled_layout.dart';
import 'package:life_os/routing/router.dart';

class LifeOsApp extends StatelessWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      builder: (context, child) => ScaledLayout.wrap(child: child!),
      routerConfig: buildRouter(),
    );
  }
}
