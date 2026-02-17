/*// lib/core/config/api_config.dart
// Configuración de API con HTTPS (Clean Code: constantes centralizadas)
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Usa dotenv.env para obtener valores, con fallbacks por si no están definidos
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://localhost:3000';
  static String get apiKey => dotenv.env['API_KEY'] ?? 'default_key';

  // Agrega más configuraciones según necesites
  static String get timeout =>
      dotenv.env['API_TIMEOUT'] ?? '30'; // En segundos, por ejemplo
  static String get version => dotenv.env['API_VERSION'] ?? 'v1';

  // Ejemplo de uso: Construye una URL completa
  static String get fullApiUrl => '$baseUrl/$version';

  // Rutas de endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String recipesEndpoint = '/api/recetas';
}*/
