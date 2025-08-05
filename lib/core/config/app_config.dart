import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ??
        (throw Exception('API_BASE_URL is missing in your .env file!'));
  }

  static String get trackfiSalt {
    return dotenv.env['TRACKFI_SALT'] ??
        (throw Exception('TRACKFI_SALT is missing in your .env file!'));
  }

  static String get sentryDsn {
    return dotenv.env['SENTRY_DSN'] ??
        (throw Exception('SENTRY_DSN is missing in your .env file!'));
  }

  static bool get isProduction {
    return dotenv.env['ENVIRONMENT'] == 'production';
  }
}
