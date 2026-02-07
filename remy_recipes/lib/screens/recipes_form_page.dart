import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remy_recipes/main.dart';
import 'dart:io';
import 'dart:convert';
import '../data/models/receta.dart';
import '../services/recetas_service.dart';
import 'package:flutter/foundation.dart';
import '../data/constants/app_strings.dart';
import 'package:logger/logger.dart';
import '../data/constants/app_strings.dart';

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
  @override
  void initState() {
    super.initState();

    logger.i('Inicializando formulario de receta - Modo: ${widget.recetaEditar == null ? "Crear" : "Editar"}');  // Log de inicio

    if (widget.recetaEditar != null) {
      final r = widget.recetaEditar!;

      titleController.text = r.titulo;
      duration = r.duracion?.toString();
      country = r.pais;
      selectedAllergens = (r.alergenos ?? '').split(',');
      season = r.estacion;

      // 👇 Ingredientes (String → Ingredient)
      ingredients = (r.ingredientes ?? []).map((i) {
        return Ingrediente(nombre: i.nombre, cantidad: i.cantidad);
      }).toList();

      steps = (r.pasos ?? []).map((p) {
        return Paso(descripcion: p.descripcion);
      }).toList();

      logger.i('Receta cargada para edición: ${r.titulo}');  // Log de carga
    }
  }

  String? imagePath;
  String title = '';
  String? duration;
  String? country;
  List<String> selectedAllergens = [];
  String? season;

  List<Ingrediente> ingredients = [];
  List<Paso> steps = [];

  final TextEditingController titleController = TextEditingController();

  final List<String> durations = List.generate(
    60,
    (index) => ((index + 1) * 5).toString(),
  ); // 5-300

  final List<String> countries = [
    "Afganistán", "Albania", "Alemania", "Andorra", "Angola","Antigua y Barbuda", "Arabia Saudita", "Argelia", "Argentina", "Armenia", "Australia", "Austria", "Azerbaiyán", "Bahamas", "Bangladés", "Barbados", "Baréin", "Bélgica",
    "Belice", "Benín", "Bielorrusia", "Birmania", "Bolivia", "Bosnia y Herzegovina", "Botsuana", "Brasil", "Brunéi", "Bulgaria", "Burkina Faso", "Burundi", "Bután", "Cabo Verde", "Camboya", "Camerún", "Canadá", "Catar", "Chad",
    "Chile", "China", "Chipre", "Ciudad del Vaticano", "Colombia", "Comoras", "Corea del Norte", "Corea del Sur", "Costa de Marfil", "Costa Rica", "Croacia", "Cuba", "Dinamarca", "Dominica", "Ecuador", "Egipto", "El Salvador", "Emiratos Árabes Unidos",
    "Eritrea","Eslovaquia", "Eslovenia", "España", "Estados Unidos", "Estonia", "Esuatini", "Etiopía", "Filipinas", "Finlandia", "Fiyi", "Francia", "Gabón", "Gambia", "Georgia", "Ghana", "Granada", "Grecia", "Guatemala", "Guinea", "Guinea-Bisáu", "Guinea Ecuatorial", "Guyana",
    "Haití", "Honduras", "Hungría", "India", "Indonesia", "Irak", "Irán", "Irlanda", "Islandia", "Islas Marshall", "Islas Salomón", "Israel", "Italia", "Jamaica", "Japón", "Jordania", "Kazajistán", "Kenia", "Kirguistán", "Kiribati", "Kuwait",
    "Laos", "Lesoto", "Letonia", "Líbano", "Liberia", "Libia", "Liechtenstein", "Lituania", "Luxemburgo", "Madagascar", "Malasia", "Malaui", "Maldivas", "Malí", "Malta", "Marruecos", "Mauricio", "Mauritania", "México", "Micronesia", "Moldavia",
    "Mónaco", "Mongolia", "Montenegro", "Mozambique", "Namibia", "Nauru", "Nepal", "Nicaragua", "Níger", "Nigeria", "Noruega", "Nueva Zelanda", "Omán", "Países Bajos", "Pakistán", "Palaos", "Panamá", "Papúa Nueva Guinea", "Paraguay", "Perú",
    "Polonia", "Portugal", "Reino Unido", "República Centroafricana", "República Checa", "República del Congo", "República Democrática del Congo", "República Dominicana", "Ruanda", "Rumanía", "Rusia", "Samoa", "San Cristóbal y Nieves", "San Marino",
    "San Vicente y las Granadinas", "Santa Lucía", "Santo Tomé y Príncipe", "Senegal", "Serbia", "Seychelles", "Sierra Leona", "Singapur", "Siria", "Somalia", "Sri Lanka", "Sudáfrica", "Sudán", "Sudán del Sur", "Suecia", "Suiza", "Surinam", "Tailandia", "Tanzania", "Tayikistán",
    "Timor Oriental", "Togo", "Tonga", "Trinidad y Tobago", "Túnez", "Turkmenistán", "Turquía", "Tuvalu", "Ucrania", "Uganda", "Uruguay", "Uzbekistán", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Yibuti", "Zambia",
    "Zimbabue",
  ];

  final List<String> allergens = [
    'Ninguna','Gluten', 'Lácteos / Lactosa',
    'Huevo', 'Frutos secos', 'Cacahuete',
    'Soja', 'Pescado', 'Mariscos',
    'Sésamo', 'Mostaza', 'Apio',
    'Sulfitos', 'Altramuces',
  ];

  final List<String> seasons = [
    'Todas',
    'Primavera',
    'Verano',
    'Otoño',
    'Invierno',
  ];
  final picker = ImagePicker();

  // ==============================================
  //               SELECCIÓN DE IMAGEN
  // ==============================================

  Future<void> pickImage() async {
    logger.i('Iniciando selección de imagen');  // Log de acción
    try{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
      logger.i('Imagen seleccionada: ${pickedFile.path}');  // Log de éxito
      } else {
        logger.w('Selección de imagen cancelada');  // Advertencia
      }
    } catch (e) {
      logger.e('Error al seleccionar imagen: $e');  // Log de error
    }
  }

  // ==============================================
  //           GESTIÓN DINÁMICA INGREDIENTES
  // ==============================================

  void addIngredient() {
    setState(() {
      ingredients.add(Ingrediente(nombre: '', cantidad: ''));
    });
    logger.i('Ingrediente agregado - Total: ${ingredients.length}');  // Log de acción
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
    logger.i('Ingrediente eliminado en índice $index - Total: ${ingredients.length}');  // Log de acción
  }

  // ==============================================
  //              GESTIÓN DINÁMICA PASOS
  // ==============================================

  void addStep() {
    setState(() {
      steps.add(Paso(descripcion: ''));
    });
    logger.i('Paso agregado - Total: ${steps.length}');
  }

  void removeStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
    logger.i('Paso eliminado en índice $index - Total: ${steps.length}');
  }

  void reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Paso item = steps.removeAt(oldIndex);
      steps.insert(newIndex, item);
    });
     logger.i('Pasos reordenados: $oldIndex → $newIndex');
  }

  // ==============================================
  //         SELECTOR MULTIPLE DE ALÉRGENOS
  // ==============================================

  void _showAllergenSelector(BuildContext context) {
    logger.i('Mostrando selector de alérgenos');
    showDialog(
      context: context,
      builder: (_) {
        List<String> tempSelection = List.from(selectedAllergens);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(AppStrings.seleccionarAlergenos),
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
                  child: const Text(AppStrings.cancelar),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedAllergens = tempSelection;
                    });
                    logger.i('Alérgenos seleccionados: ${selectedAllergens.join(", ")}');  // Log de resultado
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.aceptar),
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
    logger.d('Validando formulario');  // Debug de validación
    if (title.trim().isEmpty) {
      logger.w('Validación fallida: Título vacío');  // Advertencia
      return false;
    }
    if (imagePath == null && widget.recetaEditar?.imagenBase64 == null) {
      logger.w('Validación fallida: Imagen no seleccionada');  // Advertencia
      return false;
    }
    if (duration == null) {
      logger.w('Validación fallida: Duración no seleccionada');  // Advertencia
      return false;
    }
    if (country == null) {
      logger.w('Validación fallida: País no seleccionado');  // Advertencia
      return false;
    }
    if (selectedAllergens.isEmpty) {
      logger.w('Validación fallida: Alérgenos no seleccionados');  // Advertencia
      return false;
    }
    if (season == null) {
      logger.w('Validación fallida: Estación no seleccionada');  // Advertencia
      return false;
    }

    if (ingredients.isEmpty ||
        ingredients.any(
          (i) => i.nombre.trim().isEmpty || i.cantidad.trim().isEmpty,
        )) {
           logger.w('Validación fallida: Ingredientes incompletos');
      return false;
    }
    if (steps.isEmpty || steps.any((s) => s.descripcion.trim().isEmpty)) {
      logger.w('Validación fallida: Pasos incompletos');
      return false;
    }
    logger.i('Formulario válido');  // Log de éxito
    return true;
  }

  // ==============================================
  //           GUARDAR / ACTUALIZAR RECETA
  // ==============================================

  void onSubmit() {
    if (isFormValid()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Receta guardada con éxito'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/home'),
              child: Text('OK'),
            ),
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
            ),
          ],
        ),
      );
    }
  }

  Future<void> _guardarReceta() async {
     logger.i('Iniciando guardado de receta');
    if (!isFormValid()) {
      _mostrarError('Debe rellenar todos los campos obligatorios');
      return;
    }

    // Construimos el objeto Receta para enviar al backend
    final receta = Receta(
      id: widget.recetaEditar?.id,
      titulo: titleController.text.trim(),
      ingredientes: ingredients
          .map((i) => Ingrediente(nombre: i.nombre, cantidad: i.cantidad))
          .toList(),
      pasos: steps.map((s) => Paso(descripcion: s.descripcion)).toList(),
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
     logger.d('Datos de receta preparados: Título=${receta.titulo}, Ingredientes=${receta.ingredientes?.length}, Pasos=${receta.pasos?.length}');  // Debug (sin datos sensibles)
    //logger que no muestra datos sensibles ya que no llama al json y así no satura consola, lo dejo comentado por si acaso es necesario en un futuro.
    /*print('TOKEN: ${widget.token}');
    print('Datos enviados: ${receta.toJson()}');
    */
    bool success;

    if (widget.recetaEditar == null) {
      // MODO CREAR
      logger.i('Modo crear: Enviando receta al servidor');
      final String? recetaId = await crearRecetaEnServidor(
        receta,
        widget.token,
      );
      success = recetaId != null;
    } else {
      // MODO EDITAR
      logger.i('Modo editar: Actualizando receta en servidor');
      success = await editarReceta(receta, widget.token);
    }

    if (success) {
      Navigator.pop(
        context,
        true,
      ); // ← Devuelve true para que la lista se refresque
    } else {
      logger.e('Error al guardar receta en servidor'); 
      _mostrarError('Error al guardar la receta en el servidor');
    }
  }

  void _mostrarError(String mensaje) {
     logger.e('Mostrando error: $mensaje');  // Log de error
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.error),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
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
     logger.i('Construyendo interfaz del formulario');  // Log de construcción
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(
        title: Text(
          widget.recetaEditar == null
              ? AppStrings.anadirNuevaReceta
              : AppStrings.editarReceta,
        ),
        backgroundColor: AppStrings.colorFondo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Alegreya',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // SELECCIÓN DE IMAGEN
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.anadirImagen,
                style: TextStyle(fontSize: 20),
              ),
            ),
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
                    imagePath ==
                        null //&& widget.recetaEditar?.imagenBase64 == null
                    ? const Center(
                        child: Text('+', style: TextStyle(fontSize: 40)),
                      )
                    : kIsWeb
                    ? Image.network(
                        fit: BoxFit.fill,
                        imagePath!,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Text("Error al cargar imagen web"),
                            ),
                      )
                    // Importante: La clase File ya está importada en el inicio del archivo
                    : Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 15),

            // TÍTULO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.titulo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            TextField(
              controller: titleController,
              onChanged: (val) => title = val,
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 30),

            // INGREDIENTES DINÁMICOS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ingredientes:",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
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
                        key: ValueKey("ingredient_name_$idx"),
                        controller: TextEditingController(text: ing.nombre)
                          ..selection = TextSelection.collapsed(
                            offset: ing.nombre.length,
                          ),
                        onChanged: (val) => ing.nombre = val,
                        decoration: const InputDecoration(
                          hintText: AppStrings.ingredienteHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        key: ValueKey("ingredient_qty_$idx"),
                        controller: TextEditingController(text: ing.cantidad)
                          ..selection = TextSelection.collapsed(
                            offset: ing.cantidad.length,
                          ),
                        onChanged: (val) => ing.cantidad = val,
                        decoration: const InputDecoration(
                          hintText: AppStrings.cantidadHint,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),
                    // Botón eliminar
                    ElevatedButton(
                      onPressed: () => removeIngredient(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addIngredient,
              child: const Text('Agregar Ingrediente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStrings.colorFondo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 15),

            // Pasos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pasos:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),

                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: steps.length,
                  onReorder: reorderSteps,
                  itemBuilder: (context, idx) {
                    final step = steps[idx];
                    return Padding(
                      key: ValueKey("step_key_${step.hashCode}"),
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: idx,
                            child: const Icon(
                              Icons.drag_handle,
                              color: Colors.redAccent,
                            ),
                          ),

                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller:
                                  TextEditingController(text: step.descripcion)
                                    ..selection = TextSelection.collapsed(
                                      offset: step.descripcion.length,
                                    ),
                              onChanged: (val) => step.descripcion = val,
                              decoration: const InputDecoration(
                                hintText: 'Paso',
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          ElevatedButton(
                            onPressed: () => removeStep(idx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("-"),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: addStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStrings.colorFondo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Agregar Paso'),
                ),
                const SizedBox(height: 50),
              ],
            ),

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
                  child: GestureDetector(
                    onTap: () => _showAllergenSelector(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Alérgenos'),
                        controller: TextEditingController(
                          text: selectedAllergens.isEmpty
                              ? ''
                              : selectedAllergens.join(', '),
                        ),
                      ),
                    ),
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

            SizedBox(height: 50),

            // Botón guardar (usamos un estilo similar al de Login/Register)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarReceta,
                child: const Text(AppStrings.guardarReceta),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStrings.colorFondo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
