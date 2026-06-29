abstract final class AppConfig {
  static const appName = 'TaskFlow';

  /// Default FastAPI backend URL for local development.
  /// Use `10.0.2.2` on Android emulator, `localhost` on iOS simulator.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
}
