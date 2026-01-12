import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '/models/receta.dart';
import '/services/recetas_service.dart';
import 'package:flutter/foundation.dart';

const String _baseUrl = 'http://10.0.2.2:8000';

// ==========================================================================
//          FORMULARIO DE CREACIÓN / EDICIÓN DE RECETA
// ==========================================================================

class RecipeFormPage extends StatefulWidget {
  final Receta? recetaEditar; // Si viene con valor → modo edición
  final String token; // JWT para autenticar las peticiones al backend

  const RecipeFormPage({Key? key, required this.token, this.recetaEditar})
    : super(key: key);

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  // Variables de estado del formulario
  String? imagePath; // Ruta local de la imagen seleccionada
  final TextEditingController titleController = TextEditingController();

  String? duration; // Tiempo en minutos (string del dropdown)
  String? country;
  List<String> selectedAllergens = [];
  String? season;

  List<Ingrediente> ingredients = []; // Lista dinámica de ingredientes
  List<Paso> steps = []; // Lista dinámica de pasos

  // Listas para los dropdowns
  final List<String> durations = List.generate(
    60,
    (index) => ((index + 1) * 5).toString(),
  ); // 5,10,15...300 min
  final List<String> countries = [/* lista muy larga de países */];
  final List<String> allergens = [
    'Ninguna',
    'Gluten',
    'Lácteos / Lactosa' /* ... */,
  ];
  final List<String> seasons = [
    'Todas',
    'Primavera',
    'Verano',
    'Otoño',
    'Invierno',
  ];

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Si estamos editando una receta existente → precargamos todos los campos
    if (widget.recetaEditar != null) {
      final r = widget.recetaEditar!;
      titleController.text = r.titulo;
      duration = r.duracion?.toString();
      country = r.pais;
      selectedAllergens = (r.alergenos ?? '').split(',');
      season = r.estacion;

      ingredients = (r.ingredientes ?? [])
          .map((i) => Ingrediente(nombre: i.nombre, cantidad: i.cantidad))
          .toList();

      steps = (r.pasos ?? [])
          .map((p) => Paso(descripcion: p.descripcion))
          .toList();
    }
  }

  // ==============================================
  //               SELECCIÓN DE IMAGEN
  // ==============================================

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  // ==============================================
  //           GESTIÓN DINÁMICA INGREDIENTES
  // ==============================================

  void addIngredient() {
    setState(() {
      ingredients.add(Ingrediente(nombre: '', cantidad: ''));
    });
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  // ==============================================
  //              GESTIÓN DINÁMICA PASOS
  // ==============================================

  void addStep() {
    setState(() {
      steps.add(Paso(descripcion: ''));
    });
  }

  void removeStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  // ==============================================
  //         SELECTOR MULTIPLE DE ALÉRGENOS
  // ==============================================

  void _showAllergenSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        List<String> tempSelection = List.from(selectedAllergens);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Seleccionar alérgenos"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allergens.map((a) {
                    return CheckboxListTile(
                      title: Text(a),
                      value: tempSelection.contains(a),
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            if (!tempSelection.contains(a))
                              tempSelection.add(a);
                          } else {
                            tempSelection.remove(a);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedAllergens = tempSelection;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Aceptar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==============================================
  //               VALIDACIÓN DEL FORMULARIO
  // ==============================================

  bool isFormValid() {
    if (titleController.text.trim().isEmpty) return false;
    if (imagePath == null && widget.recetaEditar?.imagenBase64 == null)
      return false;
    if (duration == null) return false;
    if (country == null) return false;
    if (selectedAllergens.isEmpty) return false;
    if (season == null) return false;

    if (ingredients.isEmpty ||
        ingredients.any(
          (i) => i.nombre.trim().isEmpty || i.cantidad.trim().isEmpty,
        )) {
      return false;
    }
    if (steps.isEmpty || steps.any((s) => s.descripcion.trim().isEmpty)) {
      return false;
    }

    return true;
  }

  // ==============================================
  //           GUARDAR / ACTUALIZAR RECETA
  // ==============================================

  Future<void> _guardarReceta() async {
    if (!isFormValid()) {
      _mostrarError('Debe rellenar todos los campos obligatorios');
      return;
    }

    // Construimos el objeto Receta para enviar al backend
    final receta = Receta(
      id: widget.recetaEditar?.id,
      titulo: titleController.text.trim(),
      ingredientes: ingredients,
      pasos: steps,
      duracion: int.parse(duration!),
      pais: country!,
      alergenos: selectedAllergens.join(','),
      estacion: season!,
      imagenBase64: imagePath != null
          ? base64Encode(
              File(imagePath!).readAsBytesSync(),
            ) // ← Convierte archivo a base64
          : widget.recetaEditar?.imagenBase64,
    );

    print('TOKEN: ${widget.token}');
    print('Datos enviados: ${receta.toJson()}');

    bool success;

    if (widget.recetaEditar == null) {
      // MODO CREAR
      final String? recetaId = await crearRecetaEnServidor(
        receta,
        widget.token,
      );
      success = recetaId != null;
    } else {
      // MODO EDITAR
      success = await editarReceta(receta, widget.token);
    }

    if (success) {
      Navigator.pop(
        context,
        true,
      ); // ← Devuelve true para que la lista se refresque
    } else {
      _mostrarError('Error al guardar la receta en el servidor');
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ==============================================
  //                   INTERFAZ
  // ==============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(
        title: Text(
          widget.recetaEditar == null ? "Añadir Nueva Receta" : "Editar Receta",
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Remmy's Recipes",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Alegreya',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // SELECCIÓN DE IMAGEN
            const Text("Añadir imagen:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    imagePath == null &&
                        widget.recetaEditar?.imagenBase64 == null
                    ? const Center(
                        child: Text('+', style: TextStyle(fontSize: 40)),
                      )
                    : imagePath != null
                    ? (kIsWeb
                          ? Image.network(imagePath!, fit: BoxFit.cover)
                          : Image.file(File(imagePath!), fit: BoxFit.cover))
                    : Image.memory(
                        base64Decode(
                          widget.recetaEditar!.imagenBase64!.split(',').last,
                        ),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 30),

            // TÍTULO
            const Text(
              "Título:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 30),

            // INGREDIENTES DINÁMICOS
            const Text(
              "Ingredientes:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            ...ingredients.asMap().entries.map((entry) {
              int idx = entry.key;
              Ingrediente ing = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: TextEditingController(text: ing.nombre),
                        onChanged: (val) => ing.nombre = val,
                        decoration: const InputDecoration(
                          hintText: 'Ingrediente',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: TextEditingController(text: ing.cantidad),
                        onChanged: (val) => ing.cantidad = val,
                        decoration: const InputDecoration(hintText: 'Cantidad'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeIngredient(idx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('-'),
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton(
              onPressed: addIngredient,
              child: const Text('Agregar Ingrediente'),
            ),

            const SizedBox(height: 30),

            // PASOS DINÁMICOS (similar a ingredientes)

            // DROPDOWNS: DURACIÓN + PAÍS
            // DROPDOWN: ESTACIÓN + SELECTOR ALÉRGENOS (con diálogo)

            // BOTÓN GUARDAR
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarReceta,
                child: const Text('Guardar Receta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
