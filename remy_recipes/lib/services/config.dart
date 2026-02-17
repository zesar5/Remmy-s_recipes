// Descomenta la que necesites:
import '../core/config/env_config.dart';
//const String baseUrl = 'https://nondelirious-vita-unpent.ngrok-free.dev'; // URL dada por Ngrok
//const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador de Android
//const String baseUrl = 'http://localhost:8000'; // Para navegador/iOS
//const String baseUrl = 'https://192.168.1.XX:8000'; // Para dispositivo físico (tu IP local)

class ApiEndpoints {
  static String get baseUrl => Environment.apiBaseUrl;

  static String get login => '$baseUrl/usuarios/login';
  static String get register => '$baseUrl/usuarios/registro';
  static String get recetas => '$baseUrl/recetas';
  static String get perfil => '$baseUrl/usuarios/perfil';
  static String get homeRecetas => '$baseUrl/recetas/?rangoInicio=1&rangoFin=4';
  static String get obtenerRecetaUsuario => '$baseUrl/recetas/usuario';

  //Endpoints para olvidé mi contraseña

  static String get forgotPassword => '$baseUrl/usuarios/forgot-password';
  static String get verifyResetCode => '$baseUrl/usuarios/verify-reset-code';
  static String get resetPassword => '$baseUrl/usuarios/reset-password';
}
