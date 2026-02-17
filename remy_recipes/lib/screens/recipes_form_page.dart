import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remy_recipes/main.dart';
import 'dart:io';
import 'dart:convert';
import '../data/models/receta.dart';
import '../services/recetas_service.dart';
import 'package:flutter/foundation.dart';
import '../data/constants/app_strings.dart';
import '../l10n/app_localizations.dart';

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

    logger.i(
      'Inicializando formulario de receta - Modo: ${widget.recetaEditar == null ? "Crear" : "Editar"}',
    ); // Log de inicio

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

      logger.i('Receta cargada para edición: ${r.titulo}'); // Log de carga
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

  final List<String> countries = AppStrings.countries;

  final List<String> allergens = AppStrings.allergens;

  final List<String> seasons = AppStrings.seasons;

  final picker = ImagePicker();

  // ==============================================
  //               SELECCIÓN DE IMAGEN
  // ==============================================

  Future<void> pickImage() async {
    logger.i('Iniciando selección de imagen'); // Log de acción
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
        });
        logger.i('Imagen seleccionada: ${pickedFile.path}'); // Log de éxito
      } else {
        logger.w('Selección de imagen cancelada'); // Advertencia
      }
    } catch (e) {
      logger.e('Error al seleccionar imagen: $e'); // Log de error
    }
  }

  // ==============================================
  //           GESTIÓN DINÁMICA INGREDIENTES
  // ==============================================

  void addIngredient() {
    setState(() {
      ingredients.add(Ingrediente(nombre: '', cantidad: ''));
    });
    logger.i(
      'Ingrediente agregado - Total: ${ingredients.length}',
    ); // Log de acción
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
    logger.i(
      'Ingrediente eliminado en índice $index - Total: ${ingredients.length}',
    ); // Log de acción
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
              title: Text(AppLocalizations.of(context)!.seleccionarAlergenos),
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
                  child: Text(AppLocalizations.of(context)!.cancelar),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedAllergens = tempSelection;
                    });
                    logger.i(
                      'Alérgenos seleccionados: ${selectedAllergens.join(", ")}',
                    ); // Log de resultado
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.aceptar),
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
    logger.d('Validando formulario'); // Debug de validación
    if (title.trim().isEmpty) {
      logger.w('Validación fallida: Título vacío'); // Advertencia
      return false;
    }
    if (imagePath == null && widget.recetaEditar?.imagenBase64 == null) {
      logger.w('Validación fallida: Imagen no seleccionada'); // Advertencia
      return false;
    }
    if (duration == null) {
      logger.w('Validación fallida: Duración no seleccionada'); // Advertencia
      return false;
    }
    if (country == null) {
      logger.w('Validación fallida: País no seleccionado'); // Advertencia
      return false;
    }
    if (selectedAllergens.isEmpty) {
      logger.w('Validación fallida: Alérgenos no seleccionados'); // Advertencia
      return false;
    }
    if (season == null) {
      logger.w('Validación fallida: Estación no seleccionada'); // Advertencia
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
    logger.i('Formulario válido'); // Log de éxito
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
          title: Text(AppLocalizations.of(context)!.exito),
          content: Text(AppLocalizations.of(context)!.recetaGuardadaExito),
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
          title: Text(AppLocalizations.of(context)!.advertencia),
          content: Text(AppLocalizations.of(context)!.errorCamposObligatorios),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _guardarReceta() async {
    logger.i('Iniciando guardado de receta');
    if (!isFormValid()) {
      _mostrarError(AppLocalizations.of(context)!.debeRellenarCampos);
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
    logger.d(
      'Datos de receta preparados: Título=${receta.titulo}, Ingredientes=${receta.ingredientes?.length}, Pasos=${receta.pasos?.length}',
    ); // Debug (sin datos sensibles)
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
    logger.e('Mostrando error: $mensaje'); // Log de error
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
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
    logger.i('Construyendo interfaz del formulario'); // Log de construcción
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(
        title: Text(
          widget.recetaEditar == null
              ? AppLocalizations.of(context)!.anadirNuevaReceta
              : AppLocalizations.of(context)!.editarReceta,
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
            Text(
              AppLocalizations.of(context)!.appName,
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Alegreya',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // SELECCIÓN DE IMAGEN
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.anadirImagen,
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
                    imagePath !=
                        null //&& widget.recetaEditar?.imagenBase64 == null
                    ? Image.file(File(imagePath!), fit: BoxFit.cover)
                    : (widget.recetaEditar?.imagenBase64 != null &&
                              widget.recetaEditar!.imagenBase64!.isNotEmpty
                          ? Image.memory(
                              base64Decode(
                                widget.recetaEditar!.imagenBase64!
                                    .split(',')
                                    .last,
                              ),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Text('+', style: TextStyle(fontSize: 40)),
                            )),
              ),
            ),

            const SizedBox(height: 15),

            // TÍTULO
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.titulo,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.ingredientesDosPuntos,
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
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.ingredienteHint,
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
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.cantidadHint,
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
              child: Text(AppLocalizations.of(context)!.agregarIngredienteBtn),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.pasosDosPuntos,
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
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.pasoHint,
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
                  child: Text(AppLocalizations.of(context)!.agregarPasoBtn),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.duracionLabel,
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.paisLabel,
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
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.alergenosLabel,
                        ),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.estacionLabel,
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
                child: Text(AppLocalizations.of(context)!.guardarReceta),
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
