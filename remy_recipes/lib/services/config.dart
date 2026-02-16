// Descomenta la que necesites:
//const String baseUrl = 'https://nondelirious-vita-unpent.ngrok-free.dev'; // URL dada por Ngrok
//const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador de Android
const String baseUrl = 'http://localhost:8000'; // Para navegador/iOS
//const String baseUrl = 'https://192.168.1.XX:8000'; // Para dispositivo físico (tu IP local)

class ApiEndpoints {
  static const String login = '$baseUrl/usuarios/login';
  static const String register = '$baseUrl/usuarios/registro';
  static const String recetas = '$baseUrl/recetas';
  static const String perfil = '$baseUrl/usuarios/perfil';
  static const String homeRecetas =
      '$baseUrl/recetas/?rangoInicio=1&rangoFin=4';
  static const String obtenerRecetaUsuario = '$baseUrl/recetas/usuario';

  //Endpoints para olvidé mi contraseña

  static const String forgotPassword = '$baseUrl/usuarios/forgot-password';
  static const String verifyResetCode = '$baseUrl/usuarios/verify-reset-code';
  static const String resetPassword = '$baseUrl/usuarios/reset-password';

}
