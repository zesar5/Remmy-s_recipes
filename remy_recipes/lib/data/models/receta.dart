import '../constants/app_strings.dart';

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
  final String? creadorNombre;

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
    this.creadorNombre,
  });

  // Constructor factory para crear un objeto Receta desde un JSON (GET)

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['Id_receta']?.toString() ?? json['id']?.toString(),
      titulo: json['titulo']?.toString() ?? AppStrings.sinTitulo,
      ingredientes: (json['ingredientes'] as List<dynamic>?)
          ?.map(
            (i) => Ingrediente(nombre: i['nombre'], cantidad: i['cantidad']),
          )
          .toList(),
      pasos: (json['pasos'] as List<dynamic>?)
          ?.map((p) => Paso(descripcion: p['descripcion']))
          .toList(),
      duracion: json['duracion'] != null
          ? int.parse(json['duracion'].toString())
          : null,
      pais: json['pais']?.toString(),
      alergenos: json['alergenos']?.toString(),
      estacion: json['estacion']?.toString(),
      idUsuario: json['usuarioId'] as int?,
      imagenBase64: json['imagen']?.toString(),
      creadorNombre: json['creadorNombre']?.toString(),
    );
  }

  // PARA HOME (GRID)
  factory Receta.fromHomeJson(Map<String, dynamic> json) {
    print('🟢 fromHomeJson recibido: $json');
    return Receta(
      id: json['id'] != null
          ? json['id'].toString()
          : (json['Id_receta']?.toString()),
      titulo: json['titulo']?.toString() ?? 'Sin título',
      imagenBase64:
          json['imagenBase64']?.toString() ?? json['imagen']?.toString(),
    );
  }

  // Método para convertir el objeto Receta a un mapa JSON (POST/PUT)

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      //  lista de JSONs que el JS espera
      if (ingredientes != null)
        'ingredientes': ingredientes!.map((i) => i.toJson()).toList(),
      if (pasos != null) 'pasos': pasos!.map((p) => p.toJson()).toList(),
      if (duracion != null) 'duracion': duracion,
      if (pais != null) 'pais': pais,
      if (alergenos != null) 'alergenos': alergenos,
      if (estacion != null) 'estacion': estacion,
      if (idUsuario != null) 'Id_usuario': idUsuario,
      if (imagenBase64 != null) 'imagen': imagenBase64,
    };
  }
}
