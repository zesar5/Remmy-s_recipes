import 'package:remy_recipes/main.dart';
import 'package:remy_recipes/screens/recipes_form_page.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/recetas_service.dart';
import '../data/models/receta.dart';
import '../data/constants/app_strings.dart';
import 'package:logger/logger.dart';
// =======================================================
//          PANTALLA DE DETALLE DE RECETA
// =======================================================

class DetalleRecetaPage extends StatelessWidget {
  final Receta receta; // Receta completa recibida desde home o perfil
  final AuthService authService; // Para obtener token y verificar permisos

  const DetalleRecetaPage({
    Key? key,
    required this.receta,
    required this.authService,
  }) : super(key: key);

  // ==============================================
  //          DIÁLOGO DE CONFIRMACIÓN ELIMINAR
  // ==============================================

  /// Muestra diálogo de confirmación antes de eliminar la receta
  void _confirmarEliminar(BuildContext context) {
    logger.i('Mostrando diálogo de confirmación para eliminar receta: ${receta.titulo}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.eliminarReceta),
        content: const Text(AppStrings.confirmarEliminarReceta),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancelar),
          ),
          // Botón Eliminar (rojo)
          TextButton(
            onPressed: () async {
              logger.i('Confirmando eliminación de receta ID: ${receta.id}');
              try {
                // Llamada al servicio para eliminar (debe estar en recetas_service)
                await eliminarReceta(int.parse(receta.id!));
                logger.i('Receta eliminada exitosamente');  // Log de éxito

                // Cerramos el diálogo
                Navigator.pop(context);

                // Volvemos atrás y enviamos señal de "se eliminó" para que refresque la lista
                Navigator.pop(context, true);
              } catch (e) {
                logger.e('Error al eliminar receta: $e');  // Log de error
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al eliminar receta')),
                );
              }
            },
            child: const Text(
              AppStrings.eliminar,
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
    logger.i('Construyendo pantalla de detalle para receta: ${receta.titulo}');  // Log de construcción
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // AppBar con título de la receta + acciones (editar y eliminar)
      appBar: AppBar(
        title: Text(receta.titulo),
        actions: [
          // Botón EDITAR (solo visible si el usuario es propietario)
          // Nota: actualmente NO verifica propiedad → cualquiera ve los botones
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              logger.i('Navegando a edición de receta: ${receta.titulo}');
              // Navegamos al formulario de edición pasando la receta actual
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormPage(
                    token: authService.accessToken!,
                    recetaEditar:
                        receta, // ← Enviamos la receta para prellenar campos
                  ),
                ),
              );

              // Si el formulario devuelve true → hubo cambios → refrescamos
              if (actualizado == true) {
                logger.i('Receta editada - Refrescando pantalla');  // Log de resultado
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Imagen principal (si existe)
            if (receta.imagenBase64 != null) ...[
              Builder(
                builder: (context) {
                  try {
                    // Limpiamos el prefijo "data:image/...;base64,"
                    final cleanBase64 = receta.imagenBase64!.replaceFirst(
                      RegExp(r'data:image/[^;]+;base64,'),
                      '',
                    );

                    return Image.memory(
                      base64Decode(cleanBase64),
                      fit: BoxFit.cover,
                    );
                  } catch (e) {
                    logger.e('Error decodificando imagen de receta: $e');  // Log de error
                    return const Center(child: Icon(Icons.image_not_supported));
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // Sección INGREDIENTES
            const SizedBox(height: 16),
            const Text(
              AppStrings.ingredientes,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...receta.ingredientes!.map(
              (i) => Text("• ${i.cantidad} ${i.nombre}"),
            ),

            const SizedBox(height: 16),

            // Sección PASOS
            const Text(
              AppStrings.pasos,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...receta.pasos!.map((p) => Text("- ${p.descripcion}")),
          ],
        ),
      ),
    );
  }
}
