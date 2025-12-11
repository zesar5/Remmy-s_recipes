import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/receta.dart';


// import '../screens/recipes/recipes_form_page.dart';

const String _baseUrl = 'http://10.0.2.2:8000';



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
Future<String?> crearRecetaEnServidor(Receta nuevaReceta) async {
  final url = Uri.parse('$_baseUrl/recetas');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(nuevaReceta.toJson()), // Usa el método toJson() modificado
    );
   
    if (response.statusCode == 200) {
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
 Future<bool> eliminarReceta(int id) async {
    final response = await http.delete(Uri.parse("$_baseUrl/$id"));
    return response.statusCode == 200;
  }

  Future<bool> editarReceta(Receta receta) async {
    final response = await http.put(
      Uri.parse("${_baseUrl}/${receta.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(receta.toJson()),
    );

    return response.statusCode == 200;
  }

  