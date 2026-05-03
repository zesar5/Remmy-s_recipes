// ==========================================================================
//                   SERVICIO DE PAGINACIÓN CENTRALIZADO
// ==========================================================================

import 'package:remy_recipes/data/models/receta.dart';

/// Estructura de respuesta paginada del backend
class PaginatedResponse {
  final int total;
  final int pagina;
  final int totalPaginas;
  final List<dynamic> datos;

  PaginatedResponse({
    required this.total,
    required this.pagina,
    required this.totalPaginas,
    required this.datos,
  });

  /// Constructor desde JSON
  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      total: json['total'] ?? 0,
      pagina: json['pagina'] ?? 1,
      totalPaginas: json['totalPaginas'] ?? 0,
      datos: json['datos'] ?? [],
    );
  }

  /// Verifica si hay más páginas disponibles
  bool get tieneProxima => pagina < totalPaginas;

  /// Retorna la siguiente página
  int get proximaPagina => pagina + 1;
}

/// Gestor de paginación para mantener estado de recetas cargadas
class PaginationManager {
  /// Lista acumulada de recetas
  List<Receta> recetas = [];

  /// Página actual
  int paginaActual = 1;

  /// Total de recetas en la BD
  int total = 0;

  /// Total de páginas
  int totalPaginas = 0;

  /// Indica si está cargando más
  bool cargando = false;

  /// Constructor
  PaginationManager();

  /// Reinicia el estado
  void reiniciar() {
    recetas.clear();
    paginaActual = 1;
    total = 0;
    totalPaginas = 0;
    cargando = false;
  }

  /// Carga la primera página
  void cargarPrimera(PaginatedResponse response, List<Receta> nuevasRecetas) {
    recetas = nuevasRecetas;
    paginaActual = response.pagina;
    total = response.total;
    totalPaginas = response.totalPaginas;
    cargando = false;
  }

  /// Agrega más recetas (para "Cargar más")
  void cargarMas(PaginatedResponse response, List<Receta> nuevasRecetas) {
    recetas.addAll(nuevasRecetas);
    paginaActual = response.pagina;
    total = response.total;
    totalPaginas = response.totalPaginas;
    cargando = false;
  }

  /// Verifica si hay más para cargar
  bool get hayMas => paginaActual < totalPaginas;

  /// Obtiene el número de la siguiente página
  int get proximaPagina => paginaActual + 1;
}
