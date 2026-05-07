import 'package:remy_recipes/main.dart';
import 'package:remy_recipes/screens/recipes_form_page.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/config.dart';
import '../services/recetas_service.dart';
import '../data/models/receta.dart';
import '../data/constants/app_strings.dart';
import '../l10n/app_localizations.dart';
// =======================================================
//          PANTALLA DE DETALLE DE RECETA
// =======================================================

class DetalleRecetaPage extends StatefulWidget {
  final Receta receta; // Receta completa recibida desde home o perfil
  final AuthService authService; // Para obtener token y verificar permisos

  const DetalleRecetaPage({
    Key? key,
    required this.receta,
    required this.authService,
  }) : super(key: key);

  @override
  State<DetalleRecetaPage> createState() => _DetalleRecetaPageState();
}

class _DetalleRecetaPageState extends State<DetalleRecetaPage> {
  bool _liked = false;
  bool _cargandoFavorito = false;
  bool _cargandoPrivacidad = false;
  late bool _esPublica; // Estado local para el icono
  

  // ==============================================
  //        VERIFICAR SI ES PROPIETARIO
  // ==============================================
  
  /// Retorna true si el usuario actual es el creador de la receta
  bool get _esPropietario {
    final usuarioActual = widget.authService.currentUser;
    if (usuarioActual == null) return false;

    // Comparar el ID del usuario actual (convertido a int) con el ID del creador de la receta
    final userId = int.tryParse(usuarioActual.id);
    return userId != null && widget.receta.idUsuario == userId;
  }
  // ==============================================
//         CARGAR ESTADO DE FAVORITO
// ==============================================
@override
void initState(){
  super.initState();
  _esPublica = widget.receta.esPublica;
  _cargarEstadoFavorito();
}
Future<void> _cargarEstadoFavorito() async {
  if (widget.authService.currentUser == null) return;
  if (widget.receta.id == null) return;
  
  try {
    final esFav = await esFavorito(
      int.parse(widget.receta.id!),
      widget.authService.accessToken!,
    );
    
    if (mounted) {
      setState(() {
        _liked = esFav;
      });
    }
  } catch (e) {
    logger.e('Error al cargar estado de favorito: $e');
  }
}

// ==============================================
//              TOGGLE FAVORITO
// ==============================================

void _toggleLike() async {
  if (widget.authService.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.debesIniciarSesionParaLike)),
    );
    return;
  }

  if (widget.receta.id == null) return;

  final likedAnterior = _liked;
  setState(() {
    _liked = !_liked;
  });

  try {
    final esFavorito = await toggleFavorito(
      int.parse(widget.receta.id!),
      widget.authService.accessToken!,
    );
    
    if (mounted) {
      setState(() {
        _liked = esFavorito;
      });
    }
    
    logger.i(
      esFavorito
          ? '${AppLocalizations.of(context)!.likeAnyadido} ${widget.receta.id}'
          : '${AppLocalizations.of(context)!.likeQuitado} ${widget.receta.id}',
    );
  } catch (e) {
    if (mounted) {
      setState(() {
        _liked = likedAnterior;
      });
    }
  }
}

  // ==============================================
  //         CAMBIAR PRIVACIDAD DE RECETA
  // ==============================================

  /// Cambia la privacidad de la receta y actualiza el estado local
  Future<void> _cambiarPrivacidad() async {
    if (_cargandoPrivacidad) return; // Evitar múltiples llamadas
    
    setState(() => _cargandoPrivacidad = true);
    
    try {
      final nuevaPrivacidad = !_esPublica;
      final exito = await cambiarPrivacidadReceta(
        widget.receta.id!,
        nuevaPrivacidad,
        widget.authService.accessToken!,
      );
      
      if (exito && mounted) {
        // Actualizar el estado local para cambiar el icono inmediatamente
        setState(() {
          _esPublica = nuevaPrivacidad;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevaPrivacidad 
                ? 'Receta ahora es pública'
                : 'Receta ahora es privada'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        // NO salir de la pantalla - mantener al usuario aquí
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar privacidad')),
        );
      }
    } catch (e) {
      logger.e('Error cambiando privacidad: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error general')),
      );
    } finally {
      if (mounted) {
        setState(() => _cargandoPrivacidad = false);
      }
    }
  }

  // ==============================================
  //          DIÁLOGO DE CONFIRMACIÓN ELIMINAR
  // ==============================================

  /// Muestra diálogo de confirmación antes de eliminar la receta
  void _confirmarEliminar(BuildContext context) {
    logger.i(
      'Mostrando diálogo de confirmación para eliminar receta: ${widget.receta.titulo}',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.eliminarReceta),
        content: Text(AppLocalizations.of(context)!.confirmarEliminarReceta),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelar),
          ),
          // Botón Eliminar (rojo)
          TextButton(
            onPressed: () async {
              logger.i(
                'Confirmando eliminación de receta ID: ${widget.receta.id}',
              );
              try {
                final success = await eliminarReceta(
                  int.parse(widget.receta.id!),
                  widget.authService.accessToken!,
                );
                // Llamada al servicio para eliminar (debe estar en recetas_service)
                if (success) {
                  logger.i('Receta eliminada exitosamente');
                  Navigator.pop(context); // Cierra diálogo
                  Navigator.pop(context, true); // Vuelve atrás y refresca
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.errorEliminarPorPermisos,
                      ),
                    ),
                  );
                }
              } catch (e) {
                logger.e('Error al eliminar receta: $e'); // Log de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorEliminarReceta)),
                );
              }
            },
            child: Text(
              AppLocalizations.of(context)!.eliminar,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  //                  INTERFAZ PRINCIPAL
  // ==============================================

  @override
  Widget build(BuildContext context) {
   
    logger.i(
      'Construyendo pantalla de detalle para receta: ${widget.receta.titulo}',
    ); // Log de construcción
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      // AppBar con título de la receta + acciones (editar y eliminar)
      appBar: AppBar(
        title: Text(widget.receta.titulo),
        backgroundColor: AppStrings.colorFondo,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, true); // ← Devuelve true al cerrar
        },
      ),
        actions: [
          //==============================
          //BOTÓN DE FAVORITOS
          //==============================

          IconButton(
            icon: Icon(
              _liked ? Icons.favorite: Icons.favorite_border,
              color: _liked ? Colors.red : Colors.white,
            ),
            onPressed: _toggleLike,
          ),

          // Botones EDITAR y ELIMINAR solo visibles si el usuario es propietario
          if (_esPropietario) ...[
            // Botón EDITAR
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                logger.i('Navegando a edición de receta: ${widget.receta.titulo}');
                
                try {
                  // Navegamos al formulario de edición pasando la receta actual
                  final actualizado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeFormPage(
                        token: widget.authService.accessToken!,
                        recetaEditar: widget.receta,
                      ),
                    ),
                  );

                  // Solo refrescamos si hubo cambios exitosos
                  if (actualizado == true) {
                    logger.i('Receta editada - Refrescando pantalla');
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  logger.e('Error al navegar a edición: $e');
                  // Si hay error en la navegación, no refrescamos
                }
              },
            ),

            // Botón ELIMINAR
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmarEliminar(context),
            ),

            // Botón PRIVACIDAD
            IconButton(
              icon: _cargandoPrivacidad
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _esPublica ? Icons.lock_open : Icons.lock,
                    color: _esPublica ? Colors.green : Colors.orange,
                  ),
              onPressed: _cambiarPrivacidad,
              tooltip: _esPublica 
                ? 'Receta pública - Toca para hacer privada'
                : 'Receta privada - Toca para hacer pública',
            ),
          ],
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼 IMAGEN
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${ApiEndpoints.baseUrl}${widget.receta.imagenUrl}',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección INGREDIENTES
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.ingredientes,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.receta.ingredientes!.map(
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("• ${i.cantidad} ${i.nombre}"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección PASOS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pasos,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.receta.pasos!.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "${entry.key + 1}. ${entry.value.descripcion}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          //Seccion Información Adicional
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.informacion,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Duración
                  Text(
                    '${AppLocalizations.of(context)!.duracionInformacion} ${widget.receta.duracion != null ? '${widget.receta.duracion} minutos' : 'No especificada'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // País
                  Text(
                    '${AppLocalizations.of(context)!.paisInformacion} ${widget.receta.pais ?? 'No especificado'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Alérgenos (mostrados como lista con viñetas)
                  if (widget.receta.alergenos != null &&
                      widget.receta.alergenos!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.alergenosInformacion,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...widget.receta.alergenos!
                            .split(',')
                            .map(
                              (alergeno) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  "• ${alergeno.trim()}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                      ],
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.alergenosSinEspecificar,
                      style: TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  // Estación
                  Text(
                    '${AppLocalizations.of(context)!.estacionInformacion} ${widget.receta.estacion ?? 'No especificada'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 16),
            child: Text(
              '${AppLocalizations.of(context)!.creadoPor} ${widget.receta.creadorNombre ?? "Desconocido"}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF3C2415), // marrón oscuro elegante
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
