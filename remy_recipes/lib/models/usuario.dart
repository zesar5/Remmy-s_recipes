import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';

// URL base del backend (para emulador Android)
const String _baseUrl = 'http://10.0.2.2:8000';
// const String _baseUrl = 'http://localhost:8000'; // ← para desarrollo en navegador o dispositivo físico

// ==========================================================================
//                  MODELO DE DATOS: USUARIO
// ==========================================================================

class Usuario {
  final String
  id; // ID del usuario (string porque viene como número del backend)
  final String userName; // nombre de usuario (único)
  final String? pais;
  final String email;

  // Estos campos SOLO se usan en el formulario de registro
  final String contrasena; // contraseña (solo para registro)
  final String contrasena2; // confirmación (solo frontend)

  // Campos opcionales del perfil
  final String? descripcion;
  final int? anioNacimiento;
  final String? fotoPerfil; // base64 de la imagen de perfil

  Usuario({
    required this.id,
    required this.userName,
    required this.email,
    required this.contrasena,
    required this.contrasena2,
    this.pais,
    this.descripcion,
    this.anioNacimiento,
    this.fotoPerfil,
  });

  // ------------------------------------------------------------------------
  // Constructor desde JSON → usado principalmente al obtener el PERFIL
  // ------------------------------------------------------------------------
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['Id_usuario'] ?? json['id'])?.toString() ?? '',
      userName: json['nombre'] ?? '',
      pais: json['pais'],
      email: json['email'] ?? '',

      // Estos campos NO vienen en el perfil → los dejamos vacíos
      contrasena: '',
      contrasena2: '',

      descripcion: json['descripcion'],
      anioNacimiento: json['anioNacimiento'], // puede ser int o null
      // La foto podría venir como base64 completo o null
      fotoPerfil: json['fotoPerfil'],
    );
  }

  // ------------------------------------------------------------------------
  // Convierte el objeto a JSON SOLO para el REGISTRO (POST /register)
  // ------------------------------------------------------------------------
  Map<String, dynamic> toJsonRegistro() {
    return {
      'nombre': userName,
      'email': email,
      'contrasena': contrasena,
      'contrasena2': contrasena2, // el backend valida que coincidan
      if (pais != null) 'pais': pais,
      if (descripcion != null) 'descripcion': descripcion,
      if (anioNacimiento != null) 'anioNacimiento': anioNacimiento,
      if (fotoPerfil != null) 'fotoPerfil': fotoPerfil,

      // Nota importante:
      //   - No enviamos 'id' (lo genera el backend)
      //   - No enviamos otros campos que no estén en el formulario
    };
  }
}
