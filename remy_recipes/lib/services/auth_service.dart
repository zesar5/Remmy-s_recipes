import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:remy_recipes/main.dart';
import '../data/models/usuario.dart';
import 'config.dart';
import 'package:logger/logger.dart';

// ==========================================================================
//          SERVICIO CENTRAL DE AUTENTICACIÓN (AuthService)
// ==========================================================================
// Este servicio maneja todo lo relacionado con login, registro, perfil y token.
// Es el puente entre Flutter y el backend Node.js/Express

class AuthService {
  final _storage = const FlutterSecureStorage();
  // Almacenamiento en memoria del token y usuario actual
  // En producción → usar flutter_secure_storage o hive con cifrado
  String? _accessToken;
  String? get accessToken => _accessToken;

  Usuario? _currentUser;
  Usuario? get currentUser => _currentUser;
  // ==============================================
  //  MÉTODO PARA AUTO-LOGIN AL ARRANCAR
  // ==============================================
  Future<bool> tryAutoLogin() async {
    logger.i('Iniciando auto-login');
    final token = await _storage.read(key: 'jwt_token');
    final userIdStr = await _storage.read(key: 'user_id');

    if (token == null || userIdStr == null){
       logger.w('Auto-login fallido: Token o userId no encontrados en storage');
      return false;
    } 

    _accessToken = token;
    logger.d('Token cargado desde storage: [ENMASCARADO]');
    try {
      // Intentamos cargar el perfil para verificar si el token sigue vigente
      final success = await fetchProfile(int.parse(userIdStr));
      logger.i('Auto-login exitoso');  // Log de éxito
      return success;
    } catch (e) {
      // Si falla (token expirado), limpiamos todo
       logger.e('Auto-login fallido: Error al cargar perfil - $e');
      await logout();
      return false;
    }
  }

  // ==============================================
  //                     LOGIN
  // ==============================================

  /// Realiza login enviando email + contraseña al backend
  /// Si éxito → guarda token y carga perfil completo
  Future<bool> login({required String email, required String password}) async {
    final url = Uri.parse(ApiEndpoints.login);

    logger.i("ha pasado por esta funcion que es login: $email");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'contrasena': password, // ← Clave exacta que espera el backend
      }),
    );

    logger.d('Respuesta de login - Status: ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _accessToken = data['token']; // Guardamos el JWT
      final userId = int.parse(data['id'].toString());

      logger.i('Login exitoso - Guardando token y userId');  // Log de éxito
      logger.d('Token recibido: [ENMASCARADO], UserId: $userId');  // Debug enmascarado

      // NUEVO: Persistimos los datos para la próxima vez que abra la app
      await _storage.write(key: 'jwt_token', value: _accessToken);
      await _storage.write(key: 'user_id', value: userId.toString());
      // Cargamos el perfil completo usando el nuevo token
      final profileSuccess = await fetchProfile(userId);
      logger.i('Perfil cargado después de login: $profileSuccess');  // Log adicional
      return profileSuccess;
    } else {
      // Manejo de errores del backend (401, 500, etc.)
      final errorData = json.decode(response.body);
       logger.e('Login fallido: ${errorData['mensaje'] ?? 'Error desconocido'}');
      throw Exception(
        errorData['mensaje'] ?? 'Credenciales incorrectas o error de servidor.',
      );
    }
  }

  // ==============================================
  //                   REGISTRO
  // ==============================================

  /// Registra un nuevo usuario y, si éxito, hace login automático
  Future<bool> register({
    required String nombreUsuario,
    required String email,
    required String contrasena,
    required String contrasena2,
    String? pais,
    String? descripcion,
    int? anioNacimiento,
    String? fotoPerfil, // base64 completo (data:image/...;base64,...)
  }) async {
    final url = Uri.parse(ApiEndpoints.register);

     logger.i('Iniciando registro para email: $email');

    // Creamos instancia temporal del modelo Usuario solo para usar toJsonRegistro()
    final newUser = Usuario(
      id: '', // No se usa en registro
      userName: nombreUsuario,
      pais: pais,
      email: email,
      contrasena: contrasena,
      contrasena2: contrasena2,
      descripcion: descripcion,
      anioNacimiento: anioNacimiento,
      fotoPerfil: fotoPerfil,
    );

    logger.d('Datos de registro enviados: ${newUser.toJsonRegistro()}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser.toJsonRegistro()),
    );

    if (response.statusCode == 200) {
      logger.i('Registro exitoso - Iniciando login automático');
      // Registro exitoso → login automático (muy buena práctica UX)
      return await login(
        email: email,
        password: contrasena,
      );
    } else {
      // Manejo detallado de errores
      try {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['mensaje'] ?? 'Error desconocido al registrar.';
            logger.e('Registro fallido: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        logger.e('Error de servidor en registro: Status ${response.statusCode}');
        throw Exception(
          'Error de servidor (${response.statusCode}): No se pudo completar el registro.',
        );
      }
    }
  }

  // ==============================================
  //              OBTENER PERFIL DEL USUARIO
  // ==============================================

  /// Obtiene el perfil completo del usuario usando el token JWT
  /// Actualiza _currentUser con los datos del backend
  Future<bool> fetchProfile(int userId) async {
    if (_accessToken == null) {
       logger.w('Intento de fetchProfile sin token');
      return false;
    }

    final url = Uri.parse('${ApiEndpoints.perfil}/$userId');

    logger.i('Iniciando fetchProfile para userId: $userId');  // Log de inicio
    logger.d('Token presente: [ENMASCARADO]');  // Debug enmascarado

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken', // ← Token obligatorio aquí
      },
    );

    if (response.statusCode == 200) {
      // El backend devuelve directamente el objeto usuario
      // Usamos el factory fromJson que mapea correctamente los campos
      _currentUser = Usuario.fromJson(json.decode(response.body));
      logger.i('Perfil obtenido exitosamente para userId: $userId');
      return true;
    } else {
      // Si falla → limpiamos sesión (token inválido o expirado)
      logger.e('FetchProfile fallido: Status ${response.statusCode}, Body: ${response.body}');
      _accessToken = null;
      _currentUser = null;
      throw Exception(
        'Error al obtener el perfil. ID no válido o error de servidor.',
      );
    }
  }

  // ==============================================
  //                     LOGOUT
  // ==============================================

  /// Limpia la sesión actual (token y usuario)
  Future <void> logout() async {
    logger.i('Ejecutando logout - Limpiando sesión');
    _accessToken = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    logger.i('Logout completado - Datos eliminados de storage');
    // En producción: también borrar de secure storage
  }
}
