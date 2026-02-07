import 'package:remy_recipes/main.dart';
import 'package:remy_recipes/screens/recipes_form_page.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
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

  // ==============================================
  //              TOGGLE LIKE
  // ==============================================

  void _toggleLike() {
    if (widget.authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para dar like')),
      );
      return;
    }
    setState(() {
      _liked = !_liked;
    });
    logger.i(
      _liked
          ? 'Like añadido a receta ${widget.receta.id}'
          : 'Like quitado de receta ${widget.receta.id}',
    );
    //AQUI IRA LO DE BACKEND
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
                // Llamada al servicio para eliminar (debe estar en recetas_service)
                await eliminarReceta(int.parse(widget.receta.id!));
                logger.i('Receta eliminada exitosamente'); // Log de éxito

                // Cerramos el diálogo
                Navigator.pop(context);

                // Volvemos atrás y enviamos señal de "se eliminó" para que refresque la lista
                Navigator.pop(context, true);
              } catch (e) {
                logger.e('Error al eliminar receta: $e'); // Log de error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar receta')),
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
        actions: [
          // Botón EDITAR (solo visible si el usuario es propietario)
          // Nota: actualmente NO verifica propiedad → cualquiera ve los botones
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              logger.i(
                'Navegando a edición de receta: ${widget.receta.titulo}',
              );
              // Navegamos al formulario de edición pasando la receta actual
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormPage(
                    token: authService.accessToken!,
                    recetaEditar: widget
                        .receta, // ← Enviamos la receta para prellenar campos
                  ),
                ),
              );

              // Si el formulario devuelve true → hubo cambios → refrescamos
              if (actualizado == true) {
                logger.i(
                  'Receta editada - Refrescando pantalla',
                ); // Log de resultado
                Navigator.pop(context, true);
              }
            },
          ),

          // Botón ELIMINAR
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼 IMAGEN
          if (widget.receta.imagenBase64 != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(
                    widget.receta.imagenBase64!.replaceFirst(
                      RegExp(r'data:image/[^;]+;base64,'),
                      '',
                    ),
                  ),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                  const Text(
                    'Información adicional',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Duración
                  Text(
                    'Duración: ${widget.receta.duracion != null ? '${widget.receta.duracion} minutos' : 'No especificada'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // País
                  Text(
                    'País: ${widget.receta.pais ?? 'No especificado'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Alérgenos (mostrados como lista con viñetas)
                  if (widget.receta.alergenos != null && widget.receta.alergenos!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alérgenos:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        ...widget.receta.alergenos!.split(',').map(
                          (alergeno) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text("• ${alergeno.trim()}", style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Alérgenos: Ninguno especificado',
                      style: TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  // Estación
                  Text(
                    'Estación: ${widget.receta.estacion ?? 'No especificada'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 16),
            child: Text(
              'Creado por: ${widget.receta.creadorNombre ?? "Desconocido"}',
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
