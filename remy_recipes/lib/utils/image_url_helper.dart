import 'package:flutter/foundation.dart';
import '../services/config.dart';

// ==========================================================================
//              HELPER CENTRALIZADO PARA URLS DE IMÁGENES
// ==========================================================================
// Este helper asegura que las imágenes funcionen tanto en emulador como en APK
// Maneja automáticamente:
// - URLs en emulador: http://10.0.2.2:8000
// - URLs en APK/dispositivo: Lee del .env.production (NGROK o servidor remoto)
// - URLs relativas solo si BaseUrl está mal configurada
// - Paths con o sin barra inicial

class ImageUrlHelper {
  /// Construye URL de imagen optimizada para funcionar en todos los contextos
  /// 
  /// Estrategia:
  /// 1. Siempre usa ApiEndpoints.baseUrl (que ya viene del .env correcto)
  /// 2. Agrega timestamp para forzar recarga de caché
  /// 3. Normaliza paths
  static String buildImageUrl(String? imagePath, {bool includeTimestamp = true}) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Normalizar path: eliminar barra inicial si existe
    final cleanPath = imagePath.replaceFirst(RegExp(r'^/'), '');

    // ✅ SIEMPRE usar ApiEndpoints.baseUrl (lee del .env.production en APK)
    return _buildFullUrl(cleanPath, includeTimestamp);
  }

  /// Construye URL completa con timestamp opcional para forzar recarga de caché
  static String _buildFullUrl(String cleanPath, bool includeTimestamp) {
    final baseUrl = ApiEndpoints.baseUrl;
    final timestamp = includeTimestamp 
      ? '?t=${DateTime.now().millisecondsSinceEpoch}'
      : '';
    
    return '$baseUrl/$cleanPath$timestamp';
  }

  /// Alternativa: intenta detección inteligente de IP local
  /// (Útil si necesitas conectar a dispositivo físico sin cambiar config)
  static String buildImageUrlWithSmartDetection(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    final cleanPath = imagePath.replaceFirst(RegExp(r'^/'), '');

    // En emulador → URL emulador
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    // En APK/release → Usar ApiEndpoints.baseUrl (del .env)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return '${ApiEndpoints.baseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    // Web → URL completa
    if (kIsWeb) {
      return '${ApiEndpoints.baseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    // Fallback
    return '${ApiEndpoints.baseUrl}/$cleanPath';
  }
}
