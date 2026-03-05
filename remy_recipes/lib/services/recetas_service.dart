import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:remy_recipes/main.dart';
import '../data/models/receta.dart';
import 'config.dart';
import 'package:logger/logger.dart';
// ==========================================================================
//          SERVICIO DE RECETAS - CONEXIÓN CON EL BACKEND
// ==========================================================================
// Este archivo contiene TODAS las llamadas HTTP relacionadas con recetas.
// Es el punto central para CRUD y consultas de recetas.

/// Obtiene TODAS las recetas (normalmente públicas, según backend)
Future<List<Receta>> obtenerTodasLasRecetas() async {
  final url = Uri.parse('${ApiEndpoints.recetas}/recetas');
  logger.i('iniciando obtención de todas las recetas');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      logger.i('Recetas obtenidas exitosamwnte: $jsonList.length}');
      return jsonList.map((json) => Receta.fromJson(json)).toList();
    } else {
      logger.e('Error al cargar recetas: ${response.statusCode}');
      return [];
    }
  } on SocketException {
    logger.e('No hay conexión a internet o el servidor no responde.');
    return [];
  } catch (e) {
    logger.e('Error desconocido al obtener recetas: $e');
    return [];
  }
}

/// Crea una nueva receta en el servidor (POST /recetas)
/// Requiere token de autenticación
Future<String?> crearRecetaEnServidor(Receta nuevaReceta, String token) async {
  final url = Uri.parse(ApiEndpoints.recetas);

  logger.i('Iniciando creación de receta en servidor');
  logger.d(
    'Token:$token, URL: $url, Body: ${json.encode(nuevaReceta.toJson())}',
  );

  try {
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
      logger.i('Receta creada con éxito. ID: ${data['id']}');
      return data['id'].toString();
    } else {
      final errorData = json.decode(response.body);
      logger.e('Error al crear receta: ${errorData['mensaje']}');
      return null;
    }
  } catch (e) {
    logger.e('Error de conexión con el servidor: $e');
    return null;
  }
}

/// Obtiene TODAS las recetas de un usuario específico (públicas + privadas)
/// Ruta: GET /recetas/usuario/:userId
Future<List<Receta>> obtenerRecetasUsuario(String token, String userId) async {
  logger.i('➡️ LLAMANDO A /recetas/usuario/$userId');
  logger.d('🔐 TOKEN: $token');

  final response = await http.get(
    Uri.parse('${ApiEndpoints.obtenerRecetaUsuario}/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  logger.d(
    '⬅️ Respuesta recibida - Status: ${response.statusCode}, ⬅️Body: ${response.body}',
  );

  if (response.statusCode != 200) {
    logger.e(
      'Error al obtener recetas de usuario: Status ${response.statusCode}',
    );
    return [];
  }

  final decoded = json.decode(response.body);

  if (decoded is! List) {
    logger.e('El backend no devolvió una lista: $decoded');
    throw Exception('❌ El backend NO devolvió una lista');
  }

  // Usamos fromHomeJson porque la respuesta es ligera (id, título, imagen)
  final List<Receta> recetas = decoded.map<Receta>((e) {
    return Receta.fromHomeJson(e as Map<String, dynamic>);
  }).toList();
  logger.i('Recetas de usuario obtenidas: ${recetas.length}');

  return recetas;
}

/// Obtiene una receta completa por su ID (detalle)
/// Ruta: GET /recetas/:id
/// Requiere token (puede ser pública o privada del usuario)
Future<Receta> obtenerRecetaPorId(String token, String recetaId) async {
  final url = Uri.parse('${ApiEndpoints.recetas}/$recetaId');
  logger.i('Iniciando obtención de receta por ID: $recetaId');
  logger.d('Token: $token, URL: $url');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    logger.i('Receta obtenida por ID exitosamente');
    return Receta.fromJson(
      data,
    ); // ← Usa el constructor completo (ingredientes + pasos)
  } else {
    logger.e(
      'Error al obtener receta por ID: Status ${response.statusCode}, Body: ${response.body}',
    );
    throw Exception('Error al obtener receta por ID: ${response.statusCode}');
  }
}

/// Obtiene una receta SOLO si es pública (sin token)
/// Ruta: GET /recetas/publicas/:id
Future<Receta> obtenerRecetaPublicaPorId(String recetaId) async {
  final url = Uri.parse('${ApiEndpoints.recetas}/publicas/$recetaId');

  logger.i('Iniciando obtención de receta pública por ID: $recetaId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    logger.i('Receta pública obtenida exitosamente');
    return Receta.fromJson(data);
  } else {
    logger.e('Error al obtener receta pública: Status ${response.statusCode}');
    throw Exception('Error al obtener receta pública: ${response.statusCode}');
  }
}

/// Obtiene TODAS las recetas públicas (para home/exploración)
/// Ruta: GET /recetas/publicas
Future<List<Receta>> obtenerRecetasPublicas() async {
  final url = Uri.parse('${ApiEndpoints.recetas}/publicas');
  logger.i('Iniciando obtención de recetas públicas');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      logger.i('Recetas públicas obtenidas: ${data.length}');
      return data.map((e) => Receta.fromHomeJson(e)).toList();
    } else {
      logger.e('Error al obtener recetas públicas: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    logger.e('Error desconocido al obtener recetas públicas: $e');
    return [];
  }
}

/// Elimina una receta por ID
/// Ruta: DELETE /recetas/:id
/// Requiere token y ser propietario (backend lo valida)
Future<bool> eliminarReceta(int id, String token) async {
  logger.i('Iniciando eliminación de receta ID: $id');
  final response = await http.delete(
    Uri.parse('${ApiEndpoints.recetas}/$id'), // ← Faltaba /recetas/
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    logger.i('Receta eliminada exitosamente'); // Log de éxito
    return true;
  } else {
    logger.e(
      'Error al eliminar receta: Status ${response.statusCode}',
    ); // Log de error
    return false;
  }
}

/// Edita una receta existente
/// Ruta: PUT /recetas/:id
/// Requiere token y ser propietario
Future<bool> editarReceta(Receta receta, String token) async {
  logger.i('Iniciando edición de receta ID: ${receta.id}'); // Log de inicio
  logger.d('Token: $token, Body: ${jsonEncode(receta.toJson())}'); // Debug
  final response = await http.put(
    Uri.parse('${ApiEndpoints.recetas}/${receta.id}'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(receta.toJson()),
  );

  if (response.statusCode == 200) {
    logger.i('Receta editada exitosamente'); // Log de éxito
    return true;
  } else {
    logger.e(
      'Error al editar receta: Status ${response.statusCode}',
    ); // Log de error
    return false;
  }
}

//Filtrar recetas con datos introducidos por el usuario
Future<List<Receta>> recetaFiltrada({
  String? texto,
  String? pais,
  String? estacion,
  int? duracion,
  String? alergenos,
  String? token,
}) async {
  final url = Uri.parse('${ApiEndpoints.recetas}/filtrar');

  final filtros = {
    if (texto != null && texto.isNotEmpty) 'texto': texto,
    if (pais != null) 'pais': pais,
    if (estacion != null) 'estacion': estacion,
    if (duracion != null) 'duracion': duracion,
    if (alergenos != null) 'alergenos': alergenos,
  };

  logger.i('Iniciando filtro de recetas'); // Log de inicio
  logger.d('Filtros enviados: $filtros, Token: $token'); // Debug

  try {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(filtros),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      logger.i('Filtro aplicado exitosamente: ${data.length} resultados');
      return data.map((e) => Receta.fromHomeJson(e)).toList();
    } else {
      logger.e(
        'Error en filtro: Status ${response.statusCode}, Body: ${response.body}',
      );
      return [];
    }
  } catch (e) {
    logger.e('Error filtrando recetas: $e');
    return [];
  }
}

// =====================================================
//                    FUNCIONES DE FAVORITOS
// =====================================================

/// Obtiene todas las recetas favoritas del usuario
/// Ruta: GET /recetas/favoritos
Future<List<Receta>> obtenerFavoritos(String token) async {
  logger.i('Obteniendo favoritos del usuario');
  
  final url = Uri.parse('${ApiEndpoints.recetas}/favoritos');
  
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Respuesta obtenerFavoritos - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final favoritos = data.map((item) => Receta.fromHomeJson(item)).toList();
      logger.i('Favoritos obtenidos: ${favoritos.length} recetas');
      return favoritos;
    } else {
      logger.e('Error al obtener favoritos: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    logger.e('Excepción en obtenerFavoritos: $e');
    return [];
  }
}

/// Añade una receta a favoritos
/// Ruta: POST /recetas/favoritos/:recetaId
Future<bool> anadirFavorito(int recetaId, String token) async {
  logger.i('Añadiendo a favoritos receta ID: $recetaId');
  
  final url = Uri.parse('${ApiEndpoints.recetas}/favoritos/$recetaId');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Respuesta anadirFavorito - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      logger.i('Receta añadida a favoritos exitosamente');
      return true;
    } else if (response.statusCode == 400) {
      logger.w('La receta ya está en favoritos');
      return false;
    } else {
      logger.e('Error al añadir favorito: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('Excepción en anadirFavorito: $e');
    return false;
  }
}

/// Elimina una receta de favoritos
/// Ruta: DELETE /recetas/favoritos/:recetaId
Future<bool> eliminarFavorito(int recetaId, String token) async {
  logger.i('Eliminando de favoritos receta ID: $recetaId');
  
  final url = Uri.parse('${ApiEndpoints.recetas}/favoritos/$recetaId');
  
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Respuesta eliminarFavorito - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      logger.i('Receta eliminada de favoritos exitosamente');
      return true;
    } else {
      logger.e('Error al eliminar favorito: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('Excepción en eliminarFavorito: $e');
    return false;
  }
}

/// Verifica si una receta está en favoritos
/// Ruta: GET /recetas/favoritos/:recetaId/check
Future<bool> esFavorito(int recetaId, String token) async {
  logger.d('Verificando si receta $recetaId está en favoritos');
  
  final url = Uri.parse('${ApiEndpoints.recetas}/favoritos/$recetaId/check');
  
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final estaEnFavoritos = data['esFavorito'] ?? false;
      logger.d('Receta $recetaId en favoritos: $estaEnFavoritos');
      return estaEnFavoritos;
    } else {
      logger.e('Error al verificar favorito: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('Excepción en esFavorito: $e');
    return false;
  }
}

/// Toggle favorito: añade si no existe, elimina si existe
/// Ruta: POST /recetas/favoritos/:recetaId/toggle
Future<bool> toggleFavorito(int recetaId, String token) async {
  logger.i('Toggle favorito para receta ID: $recetaId');
  
  final url = Uri.parse('${ApiEndpoints.recetas}/favoritos/$recetaId/toggle');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logger.d('Respuesta toggleFavorito - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final esFavorito = data['esFavorito'] ?? false;
      logger.i('Toggle favorito completado. Estado final: $esFavorito');
      return esFavorito;
    } else {
      logger.e('Error en toggle favorito: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('Excepción en toggleFavorito: $e');
    return false;
  }
}
