// Descomenta la que necesites:
const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador de Android
// const String baseUrl = 'http://localhost:8000'; // Para navegador/iOS
// const String baseUrl = 'http://192.168.1.XX:8000'; // Para dispositivo físico (tu IP local)

class ApiEndpoints {
  static const String login = '$baseUrl/api/login';
  static const String productos = '$baseUrl/api/productos';
}