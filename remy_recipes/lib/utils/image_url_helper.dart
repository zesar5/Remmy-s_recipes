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
  /// 1. Si ya está completa, la devuelve tal cual
  /// 2. Si no, usa ApiEndpoints.baseUrl
  /// 3. Si baseUrl está vacío, usa un fallback local
  /// 4. Agrega timestamp para evitar caché obsoleto
  static String buildImageUrl(String? imagePath, {bool includeTimestamp = true}) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    final trimmedPath = imagePath.trim();

    if (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://')) {
      return _appendTimestamp(trimmedPath, includeTimestamp);
    }

    final cleanPath = trimmedPath.replaceFirst(RegExp(r'^/'), '');
    final baseUrl = ApiEndpoints.baseUrl.trim();

    if (baseUrl.isEmpty) {
      // Fallback para builds en los que el .env no se carga correctamente
      final fallbackBaseUrl = defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000'
          : 'http://localhost:8000';
      return _buildFullUrl(fallbackBaseUrl, cleanPath, includeTimestamp);
    }

    return _buildFullUrl(baseUrl, cleanPath, includeTimestamp);
  }

  static String _buildFullUrl(String baseUrl, String cleanPath, bool includeTimestamp) {
    final normalizedBaseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');
    final normalizedPath = cleanPath.replaceFirst(RegExp(r'^/'), '');
    final timestamp = includeTimestamp ? _timestampQuery() : '';
    return '$normalizedBaseUrl/$normalizedPath$timestamp';
  }

  static String _appendTimestamp(String url, bool includeTimestamp) {
    if (!includeTimestamp) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _timestampQuery() => '?t=${DateTime.now().millisecondsSinceEpoch}';

  /// Alternativa: intenta detección inteligente de IP local
  /// (Útil si necesitas conectar a dispositivo físico sin cambiar config)
  static String buildImageUrlWithSmartDetection(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    final cleanPath = imagePath.replaceFirst(RegExp(r'^/'), '');

    if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return '${ApiEndpoints.baseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    if (kIsWeb) {
      return '${ApiEndpoints.baseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    return '${ApiEndpoints.baseUrl}/$cleanPath';
  }
}
