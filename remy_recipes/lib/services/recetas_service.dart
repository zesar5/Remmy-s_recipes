import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';


// import '../screens/recipes/recipes_form_page.dart';

const String _baseUrl = 'http://10.0.2.2:8000';

// ==========================================================================
// 1. CLASES MODELO AUXILIARES
// ==========================================================================

class Ingrediente {
  final String nombre;
  final String cantidad;
  Ingrediente({required this.nombre, required this.cantidad});
  Map<String, dynamic> toJson() => {'nombre': nombre, 'cantidad': cantidad};
}

class Paso {
  final String descripcion;
  Paso({required this.descripcion});
  Map<String, dynamic> toJson() => {'descripcion': descripcion};
}


// ==========================================================================
// 2. CLASE MODELO RECETA
// ==========================================================================

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