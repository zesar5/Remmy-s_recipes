/*// lib/core/logger/logger.dart
// Logger personalizado para logs estructurados (Clean Code: centralizado)

import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Muestra stack trace
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: Level.debug, // Cambia a Level.info en producción
  );

  static void info(String message, [dynamic data]) {
    if (data != null) {
      // Convertir cualquier objeto a String
      final dataStr = data is String ? data : data.toString();
      _logger.i('$message: $dataStr');
    } else {
      _logger.i(message);
    }
  }

  static void debug(String message, [dynamic data]) {
    if (data != null) {
      // Convertir cualquier objeto a String
      final dataStr = data is String ? data : data.toString();
      _logger.d('$message: $dataStr');
    } else {
      _logger.d(message);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (stackTrace != null) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(message, error: error);
    }
  }

  static void warning(String message) {
    _logger.w(message);
  }
}*/
