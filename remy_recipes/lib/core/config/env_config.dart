import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentType { development, production }

class Environment {
  static EnvironmentType get current {
    return kReleaseMode
        ? EnvironmentType.production
        : EnvironmentType.development;
  }

  static bool get isDevelopment => current == EnvironmentType.development;
  static bool get isProduction => current == EnvironmentType.production;

  // Variables de entorno
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiTimeout => dotenv.env['API_TIMEOUT'] ?? '30000';
  static bool get allowBadCertificates =>
      dotenv.env['ALLOW_BAD_CERTIFICATES']?.toLowerCase() == 'true';

  static Future<void> initialize() async {
    final fileName = isDevelopment ? '.env.development' : '.env.production';
    await dotenv.load(fileName: fileName);
  }
}
