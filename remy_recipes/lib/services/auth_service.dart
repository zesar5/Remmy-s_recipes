import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:remy_recipes/main.dart';
import 'package:flutter/foundation.dart';
import '../data/models/usuario.dart';
import 'config.dart';
import 'session_manager.dart';
import 'api_headers_helper.dart';

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
  
  final SessionManager _sessionManager = SessionManager();
  
  // Callback para mostrar diálogo de sesión expirada
  VoidCallback? _onSessionExpiredUI;
  // ==============================================
  //  MÉTODO PARA AUTO-LOGIN AL ARRANCAR
  // ==============================================
  Future<bool> tryAutoLogin() async {
    logger.i('Iniciando auto-login');
    final token = await _storage.read(key: 'jwt_token');
    final userIdStr = await _storage.read(key: 'user_id');

    if (token == null || userIdStr == null) {
      logger.w('Auto-login fallido: Token o userId no encontrados en storage');
      return false;
    }

    _accessToken = token;
    logger.d('Token cargado desde storage: [ENMASCARADO]');
    
    // Registrar callback combinado para cuando la sesión expire
    _sessionManager.setOnSessionExpired(_handleSessionExpiredCombined);
    
    try {
      // Intentamos cargar el perfil para verificar si el token sigue vigente
      final success = await fetchProfile(int.parse(userIdStr));
      logger.i('Auto-login exitoso'); // Log de éxito
      return success;
    } catch (e) {
      // Si falla (token expirado), limpiamos todo
      logger.e('Auto-login fallido: Error al cargar perfil - $e');
      await logout();
      return false;
    }
  }
  
  /// Maneja ambas acciones: logout + mostrar diálogo UI
  Future<void> _handleSessionExpiredCombined() async {
    logger.e('🔴 SESIÓN EXPIRADA - Ejecutando logout automático');
    
    // Siempre hacer logout
    await logout();
    
    // Si hay callback de UI registrado, ejecutarlo
    if (_onSessionExpiredUI != null) {
      logger.i('Ejecutando callback de UI para mostrar diálogo');
      await Future.delayed(Duration(milliseconds: 500)); // Pequeño delay para UI
      _onSessionExpiredUI!();
    }
  }
  
  /// Registra el callback de expiración de sesión (para mostrar diálogo)
  void registerSessionExpiredCallback(VoidCallback callback) {
    logger.d('Registrando callback de sesión expirada');
    _onSessionExpiredUI = callback;
  }

  // ==============================================
  //                     LOGIN
  // ==============================================

  /// Realiza login enviando email + contraseña al backend
  /// Si éxito → guarda token y carga perfil completo
  Future<bool> login({required String email, required String password}) async {
    final url = Uri.parse(ApiEndpoints.login);

    logger.i("Iniciando login para: $email");
    final response = await http.post(
      url,
      headers: ApiHeadersHelper.basicHeaders,
      body: json.encode({
        'email': email,
        'contrasena': password, // ← Clave exacta que espera el backend
      }),
    );

    logger.d(
      'Respuesta de login - Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _accessToken = data['token']; // Guardamos el JWT
      final userId = int.parse(data['id'].toString());

      logger.i('Login exitoso - Guardando token y userId'); // Log de éxito
      logger.d(
        'Token recibido: [ENMASCARADO], UserId: $userId',
      ); // Debug enmascarado

      // NUEVO: Persistimos los datos para la próxima vez que abra la app
      await _storage.write(key: 'jwt_token', value: _accessToken);
      await _storage.write(key: 'user_id', value: userId.toString());
      // Cargamos el perfil completo usando el nuevo token
      final profileSuccess = await fetchProfile(userId);
      logger.i(
        'Perfil cargado después de login: $profileSuccess',
      ); // Log adicional
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
    );

    logger.d('Datos de registro enviados: ${newUser.toJsonRegistro()}');

    final response = await http.post(
      url,
      headers: ApiHeadersHelper.basicHeaders,
      body: json.encode(newUser.toJsonRegistro()),
    );

    if (response.statusCode == 200) {
      logger.i('Registro exitoso - Iniciando login automático');
      // Registro exitoso → login automático (muy buena práctica UX)
      return await login(email: email, password: contrasena);
    } else {
      // Manejo detallado de errores
      try {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['mensaje'] ?? 'Error desconocido al registrar.';
        logger.e('Registro fallido: $errorMessage');
        throw Exception(errorMessage);
      } catch (e) {
        logger.e(
          'Error de servidor en registro: Status ${response.statusCode}',
        );
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

    logger.i('Iniciando fetchProfile para userId: $userId'); // Log de inicio
    logger.d('Token presente: [ENMASCARADO]'); // Debug enmascarado

    final response = await http.get(
      url,
      headers: ApiHeadersHelper.withAuth(_accessToken),
    );

    if (response.statusCode == 200) {
      // El backend devuelve directamente el objeto usuario
      // Usamos el factory fromJson que mapea correctamente los campos
      _currentUser = Usuario.fromJson(json.decode(response.body));
      logger.i('Perfil obtenido exitosamente para userId: $userId');
      return true;
    }else if (response.statusCode == 401) {
      // Token expirado o inválido
      logger.e('🔴 Error 401 en fetchProfile - Sesión expirada o inválida');
      await _sessionManager.handleSessionExpiration(response.statusCode, response.body);
      _accessToken = null;
      _currentUser = null;
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    } else {
      // Si falla → limpiamos sesión (token inválido o expirado)
      logger.e(
        'FetchProfile fallido: Status ${response.statusCode}, Body: ${response.body}',
      );
      _accessToken = null;
      _currentUser = null;
      throw Exception(
        'Error al obtener el perfil. ID no válido o error de servidor.',
      );
    }
  }

  // ==============================================
  //               Prueba editar perfil
  // ==============================================
  Future<void> updateProfile({
    required String nombreUsuario,
    String? descripcion,
    String? fotoPerfil,
  }) async {
    if (_accessToken == null || _currentUser == null) {
      logger.w('Intento de updateProfile sin token o usuario actual');
      throw Exception('Usuario no autenticado');
    }

    logger.i(
      'Iniciando actualización de perfil para userId: ${_currentUser!.id}',
    );
    logger.d(
      'Datos: nombreUsuario=$nombreUsuario, descripcion=${descripcion ?? 'null'}, fotoPerfil=${fotoPerfil != null ? '[PRESENTE]' : 'null'}',
    );

    // URL con userId (similar a fetchProfile)
    final url = Uri.parse(
      '${ApiEndpoints.perfil}/${_currentUser!.id}',
    ); // Asumiendo que ApiEndpoints.perfil es la base, ej. 'https://api.com/users/profile'

    final response = await http.put(
      // O PATCH si tu backend lo usa
      url,
      headers: ApiHeadersHelper.withAuth(_accessToken),
      body: jsonEncode({
        'nombre':
            nombreUsuario, // Asegúrate de que coincida con lo que espera tu backend (ej. 'userName' o 'nombreUsuario')
        'descripcion': descripcion,
        'fotoPerfil': fotoPerfil,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Actualizar _currentUser con los datos devueltos (asumiendo que el backend devuelve el usuario actualizado)
      _currentUser = Usuario.fromJson(
        data['user'] ?? data,
      ); // Ajusta según la estructura de respuesta de tu API
      logger.i(
        'Perfil actualizado exitosamente para userId: ${_currentUser!.id}',
      );
    } else {
      logger.e(
        'Error actualizando perfil: Status ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Error al actualizar perfil: ${response.body}');
    }
  }

  Future<String?> subirFotoPerfil(File imagen) async {
    if (_accessToken == null || _currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/usuarios/foto/${_currentUser!.id}',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['Authorization'] = 'Bearer $_accessToken';

    request.files.add(
      await http.MultipartFile.fromPath(
        'profilePic',
        imagen.path,
      ),
    );

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);

      return data['ruta'];
    } else {
      throw Exception('Error subiendo foto');
    }
  }

  // ==============================================
  //          OLVIDÉ MI CONTRASEÑA
  // ==============================================

  /// Envía un código de reset al email proporcionado
  Future<bool> sendResetCode(String email) async {
    final url = Uri.parse(
      ApiEndpoints.forgotPassword,
    ); // Agrega a config.dart: 'https://tu-api.com/auth/forgot-password'

    logger.i('Enviando código de reset a: $email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      logger.i('Código de reset enviado exitosamente');
      return true;
    } else {
      final errorData = json.decode(response.body);
      logger.e(
        'Error enviando código: ${errorData['mensaje'] ?? 'Error desconocido'}',
      );
      throw Exception(errorData['mensaje'] ?? 'No se pudo enviar el código.');
    }
  }

  /// Verifica el código de reset y devuelve un token temporal
  Future<String> verifyResetCode(String code) async {
    final url = Uri.parse(
      ApiEndpoints.verifyResetCode,
    ); // Agrega a config.dart: 'https://tu-api.com/auth/verify-reset-code'

    logger.i('Verificando código de reset');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token =
          data['resetToken']; // Asume que el backend devuelve un token temporal
      logger.i('Código verificado, token recibido');
      return token;
    } else {
      final errorData = json.decode(response.body);
      logger.e(
        'Error verificando código: ${errorData['mensaje'] ?? 'Código inválido'}',
      );
      throw Exception(errorData['mensaje'] ?? 'Código inválido.');
    }
  }

  /// Resetea la contraseña usando el token temporal
  Future<bool> resetPassword(String resetToken, String newPassword) async {
    final url = Uri.parse(
      ApiEndpoints.resetPassword,
    ); // Agrega a config.dart: 'https://tu-api.com/auth/reset-password'

    logger.i('Reseteando contraseña');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'resetToken': resetToken, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      logger.i('Contraseña reseteada exitosamente');
      return true;
    } else {
      final errorData = json.decode(response.body);
      logger.e(
        'Error reseteando contraseña: ${errorData['mensaje'] ?? 'Error desconocido'}',
      );
      throw Exception(
        errorData['mensaje'] ?? 'No se pudo cambiar la contraseña.',
      );
    }
  }

  // ==============================================
  //                     LOGOUT
  // ==============================================

  /// Limpia la sesión actual (token y usuario)
  Future<void> logout() async {
    logger.i('Ejecutando logout - Limpiando sesión');
    _accessToken = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    logger.i('Logout completado - Datos eliminados de storage');
    // En producción: también borrar de secure storage
  }
}
