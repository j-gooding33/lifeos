enum Flavor { dev, prod }

class AppConfig {
  const AppConfig._(this.flavor);

  // Not `final`: re-initializing is harmless (just app config), and
  // `flutter test` shares one isolate across test files, so a `late final`
  // throws on the second file's `setUp`.
  static late AppConfig instance;

  static void initialize(Flavor flavor) {
    instance = AppConfig._(flavor);
  }

  final Flavor flavor;

  String get appName => switch (flavor) {
        Flavor.dev => 'Life OS Dev',
        Flavor.prod => 'Life OS',
      };

  bool get isDev => flavor == Flavor.dev;
}
