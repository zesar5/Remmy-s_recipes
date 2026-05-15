// ==========================================================================
//                      CONFIGURACIÓN DE ENDPOINTS
// ==========================================================================
// Descomenta la URL que corresponda según tu entorno:
//
// 1. EMULADOR ANDROID: http://10.0.2.2:8000
//    - Esta es la forma estándar de acceder a localhost desde emulador Android
//    - El puerto 8000 es donde corre el servidor Node.js/Express
//
// 2. DISPOSITIVO FÍSICO: https://192.168.1.XX:8000
//    - Reemplaza XX con los últimos octetos de tu IP local (ej: 192.168.1.100)
//    - Verifica con `ipconfig` en Windows o `ifconfig` en Mac/Linux
//    - El backend debe estar corriendo en esa máquina con esa IP
//
// 3. NAVEGADOR/iOS: http://localhost:8000
//    - Para web o simulador iOS, localhost funciona directamente
//
// 4. NGROK (para pruebas remotas): https://[ID].ngrok-free.dev
//    - URL temporal que expone tu servidor local a internet
//    - Úsala solo para testing con equipo remoto

import '../core/config/env_config.dart';

// URL ACTIVA - Selecciona UNA de las siguientes:
//const String baseUrl = 'https://nondelirious-vita-unpent.ngrok-free.dev';
const String baseUrl = 'http://10.0.2.2:8000'; // ← ACTIVO: Android Emulator
//const String baseUrl = 'http://localhost:8000';
//const String baseUrl = 'https://192.168.1.XX:8000';

class ApiEndpoints {
  static String get baseUrl => Environment.apiBaseUrl;

  static String get login => '$baseUrl/usuarios/login';
  static String get register => '$baseUrl/usuarios/registro';
  static String get recetas => '$baseUrl/recetas';
  static String get perfil => '$baseUrl/usuarios/perfil';
  static String get homeRecetas => '$baseUrl/recetas/?rangoInicio=1&rangoFin=4';
  static String get obtenerRecetaUsuario => '$baseUrl/recetas/usuario';
  static String get comunidad => '$baseUrl/usuarios/comunidad';

  //Endpoints para olvidé mi contraseña

  static String get forgotPassword => '$baseUrl/usuarios/forgot-password';
  static String get verifyResetCode => '$baseUrl/usuarios/verify-reset-code';
  static String get resetPassword => '$baseUrl/usuarios/reset-password';

  //Edpoint para subir imagenes
  static String get uploadImage => '$baseUrl/uploads/recetas';

  //Endpoint para subir imagen de perfil
  static String get uploadProfileImage => '$baseUrl/usuarios/foto';
}
