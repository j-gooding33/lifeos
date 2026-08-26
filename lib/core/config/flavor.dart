enum Flavor { dev, prod }

class AppConfig {
  const AppConfig._(this.flavor);

  static late final AppConfig instance;

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
