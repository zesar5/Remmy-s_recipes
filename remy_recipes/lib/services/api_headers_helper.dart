// ==========================================================================
//          HELPER PARA HEADERS Y AUTENTICACIÓN
// ==========================================================================
// Este archivo centraliza la lógica de construcción de headers para evitar
// duplicidad de código en los servicios. Asegura consistencia en:
// - Content-Type
// - Authorization Bearer token
// - Otros headers comunes

class ApiHeadersHelper {
  /// Headers básicos para peticiones sin autenticación
  static Map<String, String> get basicHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Headers con autenticación Bearer token
  /// Uso: ApiHeadersHelper.withAuth(token)
  static Map<String, String> withAuth(String? token) {
    final headers = {...basicHeaders};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Headers para multipart (subida de archivos)
  /// NO incluye Content-Type (http.MultipartRequest lo maneja automáticamente)
  static Map<String, String> multipartHeaders(String? token) {
    final headers = {'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
