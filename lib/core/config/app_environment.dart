enum AppEnvironment {
  development,
  staging,
  production;

  String get label => switch (this) {
    AppEnvironment.development => 'Development',
    AppEnvironment.staging => 'Staging',
    AppEnvironment.production => 'Production',
  };

  static AppEnvironment fromValue(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.name == value,
      orElse: () => AppEnvironment.development,
    );
  }
}
