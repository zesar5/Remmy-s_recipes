import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
const String _baseUrl = 'http://10.0.2.2:8000';


// ==========================================================================
// 1. MODELO DE DATOS
// ==========================================================================

class Usuario {
  final String id;
  final String userName;
  final String nombreUsuario;
  final String email;
  final String rol;
  final String? primerApellido;
  final String? segundoApellido;
  final String? descripcion;
  final String? anioNacimiento;
  final String? fotoPerfil;

  Usuario({
    required this.id,
    required this.userName,
    required this.nombreUsuario,
    required this.email,
    required this.rol,
    this.primerApellido,
    this.segundoApellido,
    this.descripcion,
    this.anioNacimiento,
    this.fotoPerfil,
  });

  // Constructor para crear un objeto Usuario desde una respuesta JSON (PerfilOut)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      userName: json['userName']as String,
      nombreUsuario: json['nombreUsuario'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      primerApellido: json['primerApellido'] as String?,
      // FastAPI devuelve las fechas como strings (e.g., "2025-11-03")
      segundoApellido: json['segundoApellido'] as String?, 
      descripcion: json['descripcion'] as String?,
      anioNacimiento: json['anioNacimiento'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
    );
  }
}