import 'dart:async';
import 'package:remy_recipes/main.dart';

// ==========================================================================
//          GESTOR DE SESIÓN - Detecta y Maneja Expiración de Token
// ==========================================================================

typedef SessionExpiredCallback = Future<void> Function();

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  
  // Callback que se ejecuta cuando la sesión expira
  SessionExpiredCallback? _onSessionExpired;
  
  // Flag para evitar múltiples logs/callbacks simultáneos
  bool _isHandlingExpiration = false;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Registra el callback que se ejecutará cuando la sesión expire
  void setOnSessionExpired(SessionExpiredCallback callback) {
    _onSessionExpired = callback;
  }

  /// Verifica si la respuesta HTTP indica que la sesión expiró
  /// Retorna true si es expiración de token, false en caso contrario
  Future<bool> handleSessionExpiration(int statusCode, String responseBody) async {
    if (statusCode != 401) {
      return false;
    }

    // Evitar múltiples triggers simultáneos
    if (_isHandlingExpiration) {
      logger.w('⏳ Ya se está procesando una expiración de sesión');
      return true;
    }

    _isHandlingExpiration = true;

    try {
      logger.e('🔴 SESIÓN EXPIRADA DETECTADA - Ejecutando callback de expiración');
      
      // Siempre ejecutar el callback si existe
      if (_onSessionExpired != null) {
        logger.i('Llamando callback de sesión expirada...');
        await _onSessionExpired!();
        logger.i('✅ Callback completado');
      } else {
        logger.w('⚠️ No hay callback registrado para sesión expirada');
      }

      return true;
    } catch (e) {
      logger.e('❌ Error al ejecutar callback de sesión expirada: $e');
      return true;
    } finally {
      _isHandlingExpiration = false;
    }
  }

  /// Resetea el estado del gestor
  void reset() {
    _isHandlingExpiration = false;
    _onSessionExpired = null;
    logger.i('SessionManager reseteado');
  }
}
