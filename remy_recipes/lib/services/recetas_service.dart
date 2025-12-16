import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:remy_recipes/main.dart';
import '../models/receta.dart';


// import '../screens/recipes/recipes_form_page.dart';

const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';



// ==========================================================================
// 3. LÓGICA DE CONEXIÓN
// ==========================================================================

//  FUNCIÓN GET
Future<List<Receta>> obtenerTodasLasRecetas() async {
  final url = Uri.parse('$_baseUrl/recetas');

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

//  FUNCIÓN POST
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
        'Authorization': 'Bearer $token',
      },
      body: json.encode(nuevaReceta.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {  // <- Acepta 201
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

Future<List<Receta>> obtenerRecetasUsuario(String token, String userId,) async {

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

  print('🧪 decoded runtimeType: ${decoded.runtimeType}');
  print('🧪 decoded value: $decoded');

  if (decoded is! List) {
    throw Exception('❌ El backend NO devolvió una lista');
  }

  final List<Receta> recetas = decoded.map<Receta>((e) {
    print('🟢 elemento del map: $e');
    return Receta.fromHomeJson(e as Map<String, dynamic>);
  }).toList();

  return recetas;
}

Future<Receta> obtenerRecetaPorId(String token, String recetaId) async {
  print("➡️ Llamando a backend para receta ID: $recetaId");
  final url = Uri.parse('$_baseUrl/recetas/$recetaId');
  print("🌐 URL completa: $url");

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  print("⬅️ Status code: ${response.statusCode}"); // <-- PRINT 3
  print("⬅️ Body: ${response.body}");

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
      print("✅ Receta recibida: $data");
      return Receta.fromJson(data); // tu modelo Receta debe parsear ingredientes y pasos
  } else {
      print("⚠️ Error al obtener receta");
      throw Exception('Error al obtener receta por ID');
  }
}

Future<Receta> obtenerRecetaPublicaPorId(String recetaId) async {
  final url = Uri.parse('$_baseUrl/recetas/publicas/$recetaId');
  print("🔎 URL receta pública: $url");

  final response = await http.get(url); // sin token
  print("⬅️ Status code: ${response.statusCode}");
  print("⬅️ Body: ${response.body}");

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print("✅ Receta recibida: $data");
    return Receta.fromJson(data);
  } else {
    print("⚠️ Error al obtener receta pública: ${response.statusCode}");
    throw Exception('Error al obtener receta pública por ID');
  }
}

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

 Future<bool> eliminarReceta(int id) async {
    final response = await http.delete(Uri.parse("$_baseUrl/$id"));
    return response.statusCode == 200;
  }

  Future<bool> editarReceta(Receta receta, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/recetas/${receta.id}'),
      headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
      body: jsonEncode(receta.toJson()),
    );

    return response.statusCode == 200;
  }

  