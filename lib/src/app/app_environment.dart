enum AppEnvironment { development, staging, production }

class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    required this.firebaseProjectId,
  });

  factory AppEnvironmentConfig.current() {
    const appEnv = String.fromEnvironment('APP_ENV');
    return AppEnvironmentConfig.parse(appEnv);
  }

  factory AppEnvironmentConfig.parse(String value) {
    final normalized = value.trim().toLowerCase();

    return switch (normalized) {
      '' || 'development' || 'dev' => const AppEnvironmentConfig(
        environment: AppEnvironment.development,
        firebaseProjectId: 'training-ai-dev',
      ),
      'staging' || 'stg' => const AppEnvironmentConfig(
        environment: AppEnvironment.staging,
        firebaseProjectId: 'training-ai-stg',
      ),
      'production' || 'prod' => const AppEnvironmentConfig(
        environment: AppEnvironment.production,
        firebaseProjectId: 'training-ai-prod',
      ),
      _ => throw ArgumentError.value(value, 'value', 'Unsupported APP_ENV'),
    };
  }

  final AppEnvironment environment;
  final String firebaseProjectId;

  bool get showsEnvironmentLabel => environment != AppEnvironment.production;

  String get label => switch (environment) {
    AppEnvironment.development => 'DEVELOPMENT',
    AppEnvironment.staging => 'STAGING',
    AppEnvironment.production => 'PRODUCTION',
  };
}
