
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
const String _baseUrl = 'http://127.0.0.1:8000';



// ... (Despues de la clase LoginScreen y antes de RegisterScreen)
// ==========================================================================
// 6. FORMULARIO DE RECETAS
// ==========================================================================

// Clases de datos auxiliares (Ingrediente y Paso)
class Ingredient {
  String name;
  Ingredient(this.name);
}

class StepItem {
  String description;
  StepItem(this.description);
}

class RecipeFormPage extends StatefulWidget {
  @override
  _RecipeFormPageState createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  String? imagePath;
  String title = '';
  String? duration;
  String? country;
  String? selectedAllergen;
  String? season;

  List<Ingredient> ingredients = [];
  List<StepItem> steps = [];

  final TextEditingController titleController = TextEditingController();

  final List<String> durations =
      List.generate(60, (index) => ((index + 1) * 5).toString()); // 5-300
  final List<String> countries = [
    'España',
    'Italia',
    'México',
    'Francia',
    'Alemania',
    'Japón',
    'China'
  ];
  final List<String> allergens = [
    'Ninguna',
    'Gluten',
    'Lácteos / Lactosa',
    'Huevo',
    'Frutos secos',
    'Cacahuete',
    'Soja',
    'Pescado',
    'Mariscos',
    'Sésamo',
    'Mostaza',
    'Apio',
    'Sulfitos',
    'Altramuces',
  ];
  final List<String> seasons = ['Todas', 'Primavera', 'Verano', 'Otoño', 'Invierno'];

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void addIngredient() {
    setState(() {
      
      ingredients.add(Ingredient(''));
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void addStep() {
    setState(() {
      steps.add(StepItem(''));
    });
  }

  void removeStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  bool isFormValid() {
    if (title.trim().isEmpty) return false;
    if (imagePath == null) return false;
    if (duration == null) return false;
    if (country == null) return false;
    if (selectedAllergen == null) return false;
    if (season == null) return false;
    if (ingredients.isEmpty || ingredients.any((i) => i.name.trim().isEmpty))
      return false;
    if (steps.isEmpty || steps.any((s) => s.description.trim().isEmpty))
      return false;
    return true;
  }

  void onSubmit() {
    if (isFormValid()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Receta guardada con éxito'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Advertencia'),
          content: Text('Error, no ha rellenado todos los campos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo definido en el Theme para consistencia
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text("Añadir Nueva Receta"),
        backgroundColor: Theme.of(context).primaryColor, // Usamos el color primario
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Remmy's Recipes",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Añadir imagen
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Añadir imagen:"),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0), // Usamos el mismo radio de borde que en el Theme
                ),
                child: imagePath == null
                    ? const Center(
                        child: Text(
                          '+',
                          style: TextStyle(fontSize: 40),
                        ),
                      )
                      : kIsWeb
                      ? Image.network(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error al cargar imagen web")),
              )
                    // Importante: La clase File ya está importada en el inicio del archivo
                    : Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            SizedBox(height: 15),

            // Título
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Título:"),
            ),
            SizedBox(height: 5),
            TextField(
              controller: titleController,
              onChanged: (val) => title = val,
              
              // Usamos el InputDecoration Theme del MaterialApp
            ),
            SizedBox(height: 15),

            // Ingredientes
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ingredientes:"),
            ),
            // ... (mapeo de ingredientes)
            ...ingredients.asMap().entries.map((entry) {
              int idx = entry.key;
              Ingredient ing = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => ing.name = val,
                        decoration: const InputDecoration(
                          hintText: 'Ingrediente',
                          // No se necesita border, fillColor, filled, ya están en el Theme
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeIngredient(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addIngredient, 
              child: const Text('Agregar Ingrediente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 15),

            // Pasos
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Pasos:"),
            ),
            // ... (mapeo de pasos)
            ...steps.asMap().entries.map((entry) {
              int idx = entry.key;
              StepItem s = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => s.description = val,
                        decoration: const InputDecoration(
                          hintText: 'Paso',
                          // No se necesita border, fillColor, filled, ya están en el Theme
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeStep(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addStep, 
              child: const Text('Agregar Paso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 20),

            // Combo boxes (Duración y País)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: duration,
                    decoration: const InputDecoration(
                      labelText: 'Duración (min)',
                      // Tema aplicado automáticamente
                    ),
                    items: durations
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => duration = val),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: country,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      // Tema aplicado automáticamente
                    ),
                    items: countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => country = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            
            // Combo boxes (Alérgenos y Estación)
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAllergen,
                    decoration: const InputDecoration(
                      labelText: 'Alérgenos',
                      // Tema aplicado automáticamente
                    ),
                    items: allergens
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedAllergen = val),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: season,
                    decoration: const InputDecoration(
                      labelText: 'Estación',
                      // Tema aplicado automáticamente
                    ),
                    items: seasons
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => season = val),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Botón guardar (usamos un estilo similar al de Login/Register)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: const Text('Guardar Receta'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}