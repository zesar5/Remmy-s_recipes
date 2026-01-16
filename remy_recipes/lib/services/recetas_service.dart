import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/receta.dart';
import 'config.dart';

// URL base del backend (emulador Android → localhost del host)
const String _baseUrl = 'http://10.0.2.2:8000';
// const String _baseUrl = 'http://localhost:8000';

// ==========================================================================
//          SERVICIO DE RECETAS - CONEXIÓN CON EL BACKEND
// ==========================================================================
// Este archivo contiene TODAS las llamadas HTTP relacionadas con recetas.
// Es el punto central para CRUD y consultas de recetas.

/// Obtiene TODAS las recetas (normalmente públicas, según backend)
Future<List<Receta>> obtenerTodasLasRecetas() async {
  final url = Uri.parse('${ApiEndpoints.recetas}/recetas');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
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

/// Crea una nueva receta en el servidor (POST /recetas)
/// Requiere token de autenticación
Future<String?> crearRecetaEnServidor(Receta nuevaReceta, String token) async {
  final url = Uri.parse('$_baseUrl/recetas');

  try {
    print('Enviando token al backend: $token');
    print('URL: $url');
    print('Body: ${json.encode(nuevaReceta.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ← Obligatorio para autenticación
      },
      body: json.encode(nuevaReceta.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      print('Receta creada con éxito. ID: ${data['id']}');
      return data['id'].toString();
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

/// Obtiene TODAS las recetas de un usuario específico (públicas + privadas)
/// Ruta: GET /recetas/usuario/:userId
Future<List<Receta>> obtenerRecetasUsuario(String token, String userId) async {
  print('➡️ LLAMANDO A /recetas/usuario/$userId');
  print('🔐 TOKEN: $token');

  final response = await http.get(
    Uri.parse('$_baseUrl/recetas/usuario/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('⬅️ STATUS CODE: ${response.statusCode}');
  print('⬅️ BODY: ${response.body}');

  if (response.statusCode != 200) {
    return [];
  }

  final decoded = json.decode(response.body);

  if (decoded is! List) {
    throw Exception('❌ El backend NO devolvió una lista');
  }

  // Usamos fromHomeJson porque la respuesta es ligera (id, título, imagen)
  final List<Receta> recetas = decoded.map<Receta>((e) {
    return Receta.fromHomeJson(e as Map<String, dynamic>);
  }).toList();

  return recetas;
}

/// Obtiene una receta completa por su ID (detalle)
/// Ruta: GET /recetas/:id
/// Requiere token (puede ser pública o privada del usuario)
Future<Receta> obtenerRecetaPorId(String token, String recetaId) async {
  final url = Uri.parse('$_baseUrl/recetas/$recetaId');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Receta.fromJson(
      data,
    ); // ← Usa el constructor completo (ingredientes + pasos)
  } else {
    throw Exception('Error al obtener receta por ID: ${response.statusCode}');
  }
}

/// Obtiene una receta SOLO si es pública (sin token)
/// Ruta: GET /recetas/publicas/:id
Future<Receta> obtenerRecetaPublicaPorId(String recetaId) async {
  final url = Uri.parse('$_baseUrl/recetas/publicas/$recetaId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Receta.fromJson(data);
  } else {
    throw Exception('Error al obtener receta pública: ${response.statusCode}');
  }
}

/// Obtiene TODAS las recetas públicas (para home/exploración)
/// Ruta: GET /recetas/publicas
Future<List<Receta>> obtenerRecetasPublicas() async {
  final url = Uri.parse('$_baseUrl/recetas/publicas');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Receta.fromHomeJson(e)).toList();
    } else {
      print('Error al obtener recetas públicas: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error desconocido al obtener recetas públicas: $e');
    return [];
  }
}

/// Elimina una receta por ID
/// Ruta: DELETE /recetas/:id
/// Requiere token y ser propietario (backend lo valida)
Future<bool> eliminarReceta(int id) async {
  final response = await http.delete(
    Uri.parse('$_baseUrl/recetas/$id'), // ← Faltaba /recetas/
    headers: {
      'Authorization': 'Bearer ', // ← ¡Falta el token aquí!
    },
  );

  return response.statusCode == 200 || response.statusCode == 204;
}

/// Edita una receta existente
/// Ruta: PUT /recetas/:id
/// Requiere token y ser propietario
Future<bool> editarReceta(Receta receta, String token) async {
  final response = await http.put(
    Uri.parse('$_baseUrl/recetas/${receta.id}'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(receta.toJson()),
  );

  return response.statusCode == 200;
}
