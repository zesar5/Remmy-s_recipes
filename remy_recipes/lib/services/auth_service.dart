import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import '../models/usuario.dart';
const String _baseUrl = 'http://127.0.0.1:8000';




// ==========================================================================
// 2. SERVICIO DE AUTENTICACION (Conexion con FastAPI)
// ==========================================================================

class AuthService {
  // Simula el almacenamiento del token de sesion (usar Secure Storage en produccion)
  
  String? _accessToken;
  Usuario? _currentUser;

  Usuario? get currentUser => _currentUser;

  Future<bool> login({required String username, required String password}) async {
    final url = Uri.parse('$_baseUrl/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        // La API de FastAPI espera 'username' y 'password' para OAuth2
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      // Despues de obtener el token, obtenemos el perfil del usuario
      return await fetchProfile();
    } else {
      // Manejo de errores de credenciales incorrectas
      throw Exception('Credenciales incorrectas o error de servidor.');
    }
  }

  Future<bool> register(Map<String, dynamic> data, {File? imageFile}) async {
    final url = Uri.parse('$_baseUrl/registro/');
    final request = http.MultipartRequest('POST', url);
    data.forEach((key, value){
      request.fields[key] = value.toString();
    }); 
    if (imageFile != null){
      request.files.add(
        await http.MultipartFile.fromPath(
          'fotoPerfil',
          imageFile.path,
        ),
      );
    }
    final streamedResponse = await request.send();
    final response =await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Registro exitoso, el backend devuelve el perfil del nuevo usuario
      _currentUser = Usuario.fromJson(json.decode(response.body));
     
      return true;
    } else {
      // Manejo de errores 
      final errorData = json.decode(response.body)['detail'];
      throw Exception(errorData.toString());
    }
  }

  Future<bool> fetchProfile() async {
    if (_accessToken == null) return false;

    final url = Uri.parse('$_baseUrl/perfil/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      _currentUser = Usuario.fromJson(json.decode(response.body));
      return true;
    } else {
      // Token invalido o expirado
      _accessToken = null;
      _currentUser = null;
      return false;
    }
  }

  void logout() {
    _accessToken = null;
    _currentUser = null;
  }
}