import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get openRouterApiKey {
    const fromDefine =
        String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['OPENROUTER_API_KEY'] ?? '';
  }

  static String get openRouterModel {
    const fromDefine = String.fromEnvironment(
      'OPENROUTER_MODEL',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['OPENROUTER_MODEL'] ?? 'deepseek/deepseek-chat';
  }

  static String get openRouterBaseUrl {
    const fromDefine = String.fromEnvironment(
      'OPENROUTER_BASE_URL',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['OPENROUTER_BASE_URL'] ??
        'https://openrouter.ai/api/v1/chat/completions';
  }

  static String get openRouterReferer {
    const fromDefine = String.fromEnvironment(
      'OPENROUTER_REFERER',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['OPENROUTER_REFERER'] ?? '';
  }

  static String get openRouterTitle {
    const fromDefine = String.fromEnvironment(
      'OPENROUTER_APP_TITLE',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['OPENROUTER_APP_TITLE'] ?? 'NutriTrack';
  }
}
