import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:remy_recipes/main.dart';
// Importamos el modelo de usuario actualizado que creamos antes
import '../models/usuario.dart';

const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';

// ==========================================================================
// 2. SERVICIO DE AUTENTICACION (Conexion con Node.js Backend)
// ==========================================================================

class AuthService {
  // Simula el almacenamiento del token de sesion (usar Secure Storage en produccion)
 
  String? _accessToken;
  String? get accessToken => _accessToken;
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  // ============================
  // LOGIN
  // ============================

  Future<bool> login({required String email, required String password}) async {
    // La ruta es CORRECTA: /auth/login
    final url = Uri.parse('$_baseUrl/usuarios/login');
   
    //print('TOKEN ENVIADO AL BACKEND: ${authService.accessToken}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${authService.accessToken}',
      },
      body: json.encode({
        'email': email, // Clave que espera Node.js para el LOGIN
        'contrasena': password, // Clave que espera Node.js para el LOGIN
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['token'];
      final userId = int.parse(data['id'].toString());
      print('TOKEN JWT GUARDADO: $_accessToken');
      print('ID USUARIO GUARDADO: $userId');
      // Usamos fetchProfile para obtener el perfil completo usando el nuevo modelo corregido
      return await fetchProfile(userId);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['mensaje'] ?? 'Credenciales incorrectas o error de servidor.');
    }
  }

 // ==========================================================================
 // FUNCIÓN DE REGISTRO CORREGIDA
 // ==========================================================================
  Future<bool> register({
    required String nombreUsuario,
    required String email,
    required String contrasena,
    required String contrasena2,
    String? pais,
    String? descripcion,
    int? anioNacimiento,
    String? fotoPerfil,
  }) async {
    final url = Uri.parse('$_baseUrl/usuarios/registro');

    // Creamos una instancia temporal del modelo solo para usar el toJsonRegistro
    final newUser = Usuario(
      id: '', // ID temporal, no se usa para el registro POST
      userName: nombreUsuario,
      pais: pais,
      email: email,
      contrasena: contrasena,
      contrasena2: contrasena2,
      descripcion: descripcion,
      anioNacimiento: anioNacimiento,
      fotoPerfil: fotoPerfil,
    );
   
    // Convertimos los datos del formulario a JSON usando el método corregido del modelo
    final response = await http.post(
  url,
  headers: {'Content-Type': 'application/json'},
  // Llama al método sin argumentos
  body: json.encode(newUser.toJsonRegistro()),
);
//lo he cambiado
    if (response.statusCode == 200) {
  // 🔗 LOGIN AUTOMÁTICO DESPUÉS DEL REGISTRO
  return await login(
    email: email,
    password: contrasena,
  );
} else {
      // Manejo de errores
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['mensaje'] ?? 'Error desconocido al registrar.';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Error de servidor (${response.statusCode}): No se pudo completar el registro.');
      }
    }
  }

  // ==========================================================================
  // FUNCIÓN FETCH PROFILE CORREGIDA (usa el nuevo modelo Usuario.fromJson)
  // ==========================================================================
  Future<bool> fetchProfile(int userId) async {
    if (_accessToken == null) return false;

    // RUTA CORRECTA: /perfil/{idUsuario}
    final url = Uri.parse('$_baseUrl/usuarios/perfil/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      // Node.js devuelve directamente el objeto Usuario Entity
      // Usamos el factory CORREGIDO que entiende 'nombre', 'id', 'email', etc.
      _currentUser = Usuario.fromJson(json.decode(response.body));
      return true;
    } else {
      _accessToken = null;
      _currentUser = null;
      throw Exception('Error al obtener el perfil. ID no válido o error de servidor.');
    }
  }

  void logout() {
    _accessToken = null;
    _currentUser = null;
  }
}