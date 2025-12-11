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
  final String? pais;
  final String email;
  final String contrasena;
   final String contrasena2;
  final String? descripcion;
  final String? anioNacimiento;
  final String? fotoPerfil;

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

  // Constructor para crear un objeto Usuario desde una respuesta JSON (PerfilOut)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      userName: json['userName']as String,
      pais: json['pais'] as String,
      email: json['email'] as String,
      contrasena: json['contrasena'] as String,
       contrasena2: json['contrasena2'] as String,
      // FastAPI devuelve las fechas como strings (e.g., "2025-11-03"),
      descripcion: json['descripcion'] as String?,
      anioNacimiento: json['anioNacimiento'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
    );

  }
   Map<String, dynamic> toJsonRegistro() {
    return {
      'userName': userName,
      'email': email,
      'contrasena': contrasena,
      'contrasena2': contrasena2,
      'pais': pais,
      'descripcion': descripcion,
      // Nota: No incluimos 'id', 'anioNacimiento' o 'fotoPerfil' si el backend los genera o no son necesarios para el REGISTRO inicial.
    };
  }
}