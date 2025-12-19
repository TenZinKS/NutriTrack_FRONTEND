class AppConfig {
  static const openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
  static const openRouterModel = String.fromEnvironment(
    'OPENROUTER_MODEL',
    defaultValue: 'deepseek/deepseek-chat',
  );
  static const openRouterBaseUrl = String.fromEnvironment(
    'OPENROUTER_BASE_URL',
    defaultValue: 'https://openrouter.ai/api/v1/chat/completions',
  );
  static const openRouterReferer = String.fromEnvironment(
    'OPENROUTER_REFERER',
    defaultValue: '',
  );
  static const openRouterTitle = String.fromEnvironment(
    'OPENROUTER_APP_TITLE',
    defaultValue: 'NutriTrack',
  );
}
