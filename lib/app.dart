import 'package:flutter/material.dart';
import 'package:life_os/core/config/flavor.dart';

class LifeOsApp extends StatelessWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.instance.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F5BD5),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F5BD5),
        brightness: Brightness.dark,
      ),
      home: const _NotBuiltYetScreen(),
    );
  }
}

/// Honest placeholder for the project-setup milestone (M1). There is no
/// feature UI yet — the navigation shell lands in M3. This screen exists so
/// the app never presents fake or stub functionality (CLAUDE.md rule 1).
class _NotBuiltYetScreen extends StatelessWidget {
  const _NotBuiltYetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConfig.instance.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Milestone 1 — project setup. Nothing is built yet.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
