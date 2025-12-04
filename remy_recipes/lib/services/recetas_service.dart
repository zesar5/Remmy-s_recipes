import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io'; 

// Importa tu otra pantalla si es necesario
 import '../screens/recipes/recipes_form_page.dart'; 

// URL Base del servidor Node.js
// 10.0.2.2 es la IP especial para que el emulador de Android acceda a localhost de tu PC.
const String _baseUrl = 'http://10.0.2.2:8000';

// ==========================================================================
// CLASE MODELO RECETA
// ==========================================================================

class Receta {
  final String? id; 
  final String titulo;
  final String ingredientes;
  final String pasos;
  final int duracion; 
  final String pais;
  final String alergenos;
  final String estacion;
  final int idUsuario; 

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
  });

  // Constructor factory para crear un objeto Receta desde un JSON (GET)
  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['Id_receta']?.toString(), 
      titulo: json['titulo'] as String,
      ingredientes: json['ingredientes'] as String,
      pasos: json['pasos'] as String,
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
      'ingredientes': ingredientes, 
      'pasos': pasos, 
      'duracion': duracion, 
      'pais': pais,
      'alergenos': alergenos,
      'estacion': estacion,
      'idUsuario': idUsuario, // Nombre del campo que espera el JS
    };
  }
}

// ==========================================================================
// LÓGICA DE CONEXIÓN (Servicios HTTP)
// ==========================================================================

//  FUNCIÓN GET 
Future<List<Receta>> obtenerTodasLasRecetas() async {
  final url = Uri.parse('$_baseUrl/recetas');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON y la convierte en una lista de objetos Dart
      final List<dynamic> jsonList = json.decode(response.body);
      // Mapea cada elemento JSON a un objeto Receta usando el factory constructor
      return jsonList.map((json) => Receta.fromJson(json)).toList();
    } else {
      print('Error al cargar recetas: ${response.statusCode}');
      return [];
    }
  } on SocketException {
    print('No hay conexión a internet o el servidor no responde.');
    return [];
  } catch (e) {
    print('Error desconocido al obtener recetas: $e');
    return [];
  }
}

//  FUNCIÓN POST 
Future<String?> crearRecetaEnServidor(Receta nuevaReceta) async {
  final url = Uri.parse('$_baseUrl/recetas');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(nuevaReceta.toJson()), // Usa el método toJson()
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Receta creada con éxito. ID: ${data['id']}');
      return data['id'].toString(); // Devuelve el nuevo ID
    } else {
      final errorData = json.decode(response.body);
      print('Error al crear receta: ${errorData['mensaje']}');
      return null;
    }
  } catch (e) {
    print('Error de conexión con el servidor: $e');
    return null;
  }
}


