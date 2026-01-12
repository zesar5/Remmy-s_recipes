import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../screens/login/login_screen.dart';
import '../screens/register/register_screen.dart';

// URL base del backend (emulador Android apunta a 10.0.2.2)
// En producción deberías usar una variable de entorno o configuración
const String _baseUrl = 'http://10.0.2.2:8000';
// const String _baseUrl = 'http://localhost:8000'; // ← para desarrollo en navegador o físico

// ==========================================================================
// 1. MODELOS AUXILIARES (Ingrediente y Paso)
// ==========================================================================

/// Representa un ingrediente de la receta
class Ingrediente {
  String nombre;
  String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});

  /// Convierte el ingrediente a formato JSON que espera el backend
  Map<String, dynamic> toJson() => {'nombre': nombre, 'cantidad': cantidad};
}

/// Representa un paso/instrucción de la receta
class Paso {
  String descripcion;

  Paso({required this.descripcion});

  /// Formato JSON para enviar al backend
  Map<String, dynamic> toJson() => {'descripcion': descripcion};
}

// ==========================================================================
// 2. MODELO PRINCIPAL: RECETA
// ==========================================================================

class Receta {
  final String? id; // Puede ser null al crear (se genera en backend)
  final String titulo;
  final List<Ingrediente>? ingredientes;
  final List<Paso>? pasos;
  final int? duracion; // tiempo_preparacion en minutos
  final String? pais; // origen
  final String? alergenos;
  final String? estacion;
  final int? idUsuario; // propietario
  final String? imagenBase64; // imagen codificada en base64

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

  // ------------------------------------------------------------------------
  // Constructor desde JSON → usado principalmente en GET detalle de receta
  // ------------------------------------------------------------------------
  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['Id_receta']?.toString() ?? json['id']?.toString(),
      titulo: json['titulo']?.toString() ?? 'Sin título',

      // Ingredientes viene como lista de mapas
      ingredientes: (json['ingredientes'] as List<dynamic>?)
          ?.map(
            (i) => Ingrediente(
              nombre: i['nombre'] ?? '',
              cantidad: i['cantidad'] ?? '',
            ),
          )
          .toList(),

      // Pasos viene como lista de mapas con 'descripcion'
      pasos: (json['pasos'] as List<dynamic>?)
          ?.map((p) => Paso(descripcion: p['descripcion'] ?? ''))
          .toList(),

      duracion: json['duracion'] != null
          ? int.tryParse(
              json['duracion'].toString(),
            ) // más seguro que parse directo
          : null,

      pais: json['pais']?.toString(),
      alergenos: json['alergenos']?.toString(),
      estacion: json['estacion']?.toString(),
      idUsuario: json['usuarioId'] as int?,
      imagenBase64: json['imagen']
          ?.toString(), // viene como data:image/...;base64,...
    );
  }

  // ------------------------------------------------------------------------
  // Constructor especial para la vista HOME / grid / exploración
  // (respuesta más ligera: solo id, título e imagen)
  // ------------------------------------------------------------------------
  factory Receta.fromHomeJson(Map<String, dynamic> json) {
    print('🟢 fromHomeJson recibido: $json'); // ← útil para depuración

    return Receta(
      id: json['id']?.toString() ?? json['Id_receta']?.toString(),
      titulo: json['titulo']?.toString() ?? 'Sin título',
      imagenBase64: json['imagenBase64'] as String?,
    );
  }

  // ------------------------------------------------------------------------
  // Convierte el objeto Receta a JSON para enviar al backend (POST / PUT)
  // ------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,

      // Solo enviamos si existen (evitamos nulls innecesarios)
      if (ingredientes != null && ingredientes!.isNotEmpty)
        'ingredientes': ingredientes!.map((i) => i.toJson()).toList(),

      if (pasos != null && pasos!.isNotEmpty)
        'pasos': pasos!.map((p) => p.toJson()).toList(),

      if (duracion != null) 'duracion': duracion,
      if (pais != null) 'pais': pais,
      if (alergenos != null) 'alergenos': alergenos,
      if (estacion != null) 'estacion': estacion,

      // Nota: idUsuario normalmente NO se envía en creación (lo pone el backend desde token)
      //if (idUsuario != null) 'Id_usuario': idUsuario,
      if (imagenBase64 != null) 'imagen': imagenBase64,
    };
  }
}
