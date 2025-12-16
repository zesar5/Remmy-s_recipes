import 'package:remy_recipes/screens/recipes/recipes_form_page.dart';

import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import 'package:remy_recipes/screens/home/home_screen.dart' hide Receta;
import '../recipes/recipes_form_page.dart';
import 'dart:convert';
import '../../services/recetas_service.dart';
import '../../models/receta.dart';

class DetalleRecetaPage extends StatelessWidget {
  final Receta receta;
  final AuthService authService;

  const DetalleRecetaPage({Key? key, required this.receta, required this.authService,}) : super(key: key);

  @override
  void _confirmarEliminar(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar receta'),
      content: const Text('¿Seguro que deseas eliminar esta receta?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await eliminarReceta(int.parse(receta.id!));
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text(receta.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormPage(token: authService.accessToken!, recetaEditar: receta),
                ),
              );

              if (actualizado == true) {
                Navigator.pop(context, true);
              }
            },
          ),
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
            if (receta.imagenBase64 != null)
              Image.memory(
                base64Decode(receta.imagenBase64!),
              ),
            const SizedBox(height: 16),
            const Text("Ingredientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...receta.ingredientes!.map(
              (i) => Text("• ${i.cantidad} ${i.nombre}"),
            ),
            const SizedBox(height: 16),
            const Text("Pasos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...receta.pasos!.map(
              (p) => Text("- ${p.descripcion}"),
            ),
          ],
        ),
      ),
    );
  }
}