import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
const String _baseUrl = 'http://10.0.2.2:8000';

// ==========================================================================
// 1. CLASES MODELO AUXILIARES
// ==========================================================================

class Ingrediente {
  String nombre;
  String cantidad;
  Ingrediente({required this.nombre, required this.cantidad});
  Map<String, dynamic> toJson() => {'nombre': nombre, 'cantidad': cantidad};
}

class Paso {
  String descripcion;
  Paso({required this.descripcion});
  Map<String, dynamic> toJson() => {'descripcion': descripcion};
}

class Receta {
  final String? id;
  final String titulo;
  final List<Ingrediente> ingredientes;
  final List<Paso> pasos;
  final int duracion;
  final String pais;
  final String alergenos;
  final String estacion;
  final int idUsuario;
  final String? imagenBase64;

  Receta({
    this.id,
    required this.titulo,
    required this.ingredientes,
    required this.pasos,
    required this.duracion,
    required this.pais,
    required this.alergenos,
    required this.estacion,
    required this.idUsuario,
    this.imagenBase64,
  });

  // Constructor factory para crear un objeto Receta desde un JSON (GET)

  factory Receta.fromJson(Map<String, dynamic> json) {
   
    return Receta(
      id: json['Id_receta']?.toString(),
      titulo: json['titulo'] as String,
      ingredientes: (json['ingredientes'] as String).split(',').map((name) => Ingrediente(nombre: name.trim(), cantidad: '')).toList(),
      pasos: (json['pasos'] as String).split('\n').map((desc) => Paso(descripcion: desc.trim())).toList(),
      duracion: json['tiempo_preparacion'] as int,
      pais: json['origen'] as String,
      alergenos: json['alergenos'] as String,
      estacion: json['estacion'] as String,
      idUsuario: json['Id_usuario'] as int,
    );
  }

  // Método para convertir el objeto Receta a un mapa JSON (POST/PUT)
 
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      //  lista de JSONs que el JS espera
      'ingredientes': ingredientes.map((i) => i.toJson()).toList(),
      'pasos': pasos.map((p) => p.toJson()).toList(),
      'duracion': duracion,
      'pais': pais,
      'alergenos': alergenos,
      'estacion': estacion,
      'Id_usuario': idUsuario,
     
      if (imagenBase64 != null) 'imagen': imagenBase64,
    };
  }
}

