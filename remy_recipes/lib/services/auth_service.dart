import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../services/config.dart';

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
    final token = await _storage.read(key: 'jwt_token');
    final userIdStr = await _storage.read(key: 'user_id');

    if (token == null || userIdStr == null) return false;

    _accessToken = token;
    try {
      // Intentamos cargar el perfil para verificar si el token sigue vigente
      return await fetchProfile(int.parse(userIdStr));
    } catch (e) {
      // Si falla (token expirado), limpiamos todo
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

    print("ha pasado por esta funcion que es login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'contrasena': password, // ← Clave exacta que espera el backend
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _accessToken = data['token']; // Guardamos el JWT
      final userId = int.parse(data['id'].toString());

      // NUEVO: Persistimos los datos para la próxima vez que abra la app
      await _storage.write(key: 'jwt_token', value: _accessToken);
      await _storage.write(key: 'user_id', value: userId.toString());
      // Cargamos el perfil completo usando el nuevo token
      return await fetchProfile(userId);
    } else {
      // Manejo de errores del backend (401, 500, etc.)
      final errorData = json.decode(response.body);
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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newUser.toJsonRegistro()),
    );

    if (response.statusCode == 200) {
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
        throw Exception(errorMessage);
      } catch (e) {
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
    if (_accessToken == null) return false;

    final url = Uri.parse('${ApiEndpoints.perfil}/$userId');

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
      return true;
    } else {
      // Si falla → limpiamos sesión (token inválido o expirado)
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
    _accessToken = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_id');
    // En producción: también borrar de secure storage
  }
}
