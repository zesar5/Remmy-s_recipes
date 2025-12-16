import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';
const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';

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
  final List<Ingrediente>? ingredientes;
  final List<Paso>? pasos;
  final int? duracion;
  final String? pais;
  final String? alergenos;
  final String? estacion;
  final int? idUsuario;
  final String? imagenBase64;

  Receta({
    this.id,
    required this.titulo,
    this.ingredientes,
    this.pasos,
    this.duracion,
    this.pais,
    this.alergenos,
    this.estacion,
    this.idUsuario,
    this.imagenBase64,
  });

  // Constructor factory para crear un objeto Receta desde un JSON (GET)

  factory Receta.fromJson(Map<String, dynamic> json) {
   
    return Receta(
      id: json['Id_receta']?.toString(),
      titulo: json['titulo'] as String,
      ingredientes: (json['ingredientes'] as List<dynamic>?)
        ?.map((i) => Ingrediente(nombre: i['nombre'], cantidad: i['cantidad']))
        .toList(),
      pasos: (json['pasos'] as List<dynamic>?)
        ?.map((p) => Paso(descripcion: p['descripcion']))
        .toList(),
      duracion: json['duracion'] != null
        ? int.parse(json['duracion'].toString())
        : null,
      pais: json['pais'] as String,
      alergenos: json['alergenos'] as String,
      estacion: json['estacion'] as String,
      idUsuario: json['usuarioId'] as int,
      imagenBase64: json['imagen'] as String?,
    );
  }

  // PARA HOME (GRID)
  factory Receta.fromHomeJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] != null ? json['id'].toString() : (json['Id_receta']?.toString()),
      titulo: json['titulo'] as String,
      imagenBase64: json['imagenBase64'] as String?,
    );
  }

  // Método para convertir el objeto Receta a un mapa JSON (POST/PUT)
 
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      //  lista de JSONs que el JS espera
      if (ingredientes != null)'ingredientes': ingredientes!.map((i) => i.toJson()).toList(),
      if (pasos != null)'pasos': pasos!.map((p) => p.toJson()).toList(),
      if (duracion != null)'duracion': duracion,
      if (pais != null)'pais': pais,
      if (alergenos != null)'alergenos': alergenos,
      if (estacion != null)'estacion': estacion,
      if (idUsuario != null) 'Id_usuario': idUsuario,
     
      if (imagenBase64 != null) 'imagen': imagenBase64,
    };
  }
}

