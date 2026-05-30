import 'app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableHttpLogs,
    required this.enableVerboseLogs,
    required this.useMockAuth,
    required this.useMockData,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableHttpLogs;
  final bool enableVerboseLogs;
  final bool useMockAuth;
  final bool useMockData;

  static const String appName = 'ACES';

  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;
  String get environmentLabel => environment.label;
  String get appTitle =>
      isProduction ? appName : '$appName (${environment.label})';

  factory AppConfig.fromEnvironment() {
    const environmentValue = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );
    const enableHttpLogs = bool.fromEnvironment(
      'ENABLE_HTTP_LOGS',
      defaultValue: true,
    );
    const enableVerboseLogs = bool.fromEnvironment(
      'ENABLE_VERBOSE_LOGS',
      defaultValue: true,
    );
    const useMockAuth = bool.fromEnvironment(
      'USE_MOCK_AUTH',
      defaultValue: false,
    );
    const useMockData = bool.fromEnvironment(
      'USE_MOCK_DATA',
      defaultValue: false,
    );

    return AppConfig(
      environment: AppEnvironment.fromValue(environmentValue),
      apiBaseUrl: apiBaseUrl,
      enableHttpLogs: enableHttpLogs,
      enableVerboseLogs: enableVerboseLogs,
      useMockAuth: useMockAuth,
      useMockData: useMockData,
    );
  }
}
