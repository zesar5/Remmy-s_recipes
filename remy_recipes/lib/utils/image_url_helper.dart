import 'package:flutter/foundation.dart';
import '../services/config.dart';

// ==========================================================================
//              HELPER CENTRALIZADO PARA URLS DE IMÁGENES
// ==========================================================================
// Este helper asegura que las imágenes funcionen tanto en emulador como en APK
// Maneja automáticamente:
// - URLs en emulador (http://10.0.2.2:8000)
// - URLs en dispositivo físico (http://192.168.x.x:8000)
// - URLs relativas (para mayor compatibilidad)
// - Paths con o sin barra inicial

class ImageUrlHelper {
  /// Construye URL de imagen optimizada para funcionar en todos los contextos
  /// 
  /// Estrategia:
  /// 1. Si es web → URL completa
  /// 2. Si es Android/iOS → intenta path relativo primero
  /// 3. Fallback a URL completa con timestamp para forzar recarga
  static String buildImageUrl(String? imagePath, {bool includeTimestamp = true}) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // Normalizar path: eliminar barra inicial si existe
    final cleanPath = imagePath.replaceFirst(RegExp(r'^/'), '');

    // En desarrollo/emulador: usar URL completa
    if (kDebugMode) {
      return _buildFullUrl(cleanPath, includeTimestamp);
    }

    // En APK (release): intentar path relativo primero
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      // URL relativa: funciona si el servidor está en el mismo host
      return '/$cleanPath';
    }

    // Fallback: URL completa
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

    // En APK/release → URL relativa (más compatible)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return '/$cleanPath';
    }

    // Web → URL completa
    if (kIsWeb) {
      return '${ApiEndpoints.baseUrl}/$cleanPath';
    }

    // Fallback
    return '/$cleanPath';
  }
}
