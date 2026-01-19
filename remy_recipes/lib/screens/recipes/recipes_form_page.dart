import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '/models/receta.dart';
import '/services/recetas_service.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_strings.dart';

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

    if (widget.recetaEditar != null) {
      final r = widget.recetaEditar!;

      titleController.text = r.titulo;
      duration = r.duracion?.toString();
      country = r.pais;
      selectedAllergens = (r.alergenos ?? '').split(',');
      season = r.estacion;

      // 👇 Ingredientes (String → Ingredient)
      ingredients = (r.ingredientes??[]).map((i) {
        return Ingrediente(
          nombre: i.nombre,
          cantidad: i.cantidad,
        );
      }).toList();

      steps = (r.pasos??[]).map((p) {
         return Paso(descripcion: p.descripcion);
      }).toList();
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
 
  final List<String> durations =
    List.generate(60, (index) => ((index + 1) * 5).toString()); // 5-300

  final List<String> countries = [
    "Afganistán", "Albania", "Alemania", "Andorra", "Angola", "Antigua y Barbuda", "Arabia Saudita", "Argelia","Argentina", "Armenia", "Australia", "Austria", "Azerbaiyán", "Bahamas", "Bangladés", "Barbados",
    "Baréin", "Bélgica", "Belice", "Benín", "Bielorrusia", "Birmania", "Bolivia", "Bosnia y Herzegovina",
    "Botsuana", "Brasil", "Brunéi", "Bulgaria", "Burkina Faso", "Burundi", "Bután", "Cabo Verde", "Camboya", "Camerún", "Canadá", "Catar", "Chad", "Chile", "China", "Chipre", 
    "Ciudad del Vaticano", "Colombia", "Comoras", "Corea del Norte", "Corea del Sur", "Costa de Marfil",
    "Costa Rica", "Croacia", "Cuba", "Dinamarca", "Dominica", "Ecuador", "Egipto", "El Salvador", "Emiratos Árabes Unidos", "Eritrea", "Eslovaquia", "Eslovenia", "España", "Estados Unidos", "Estonia", "Esuatini",
    "Etiopía", "Filipinas", "Finlandia", "Fiyi", "Francia", "Gabón", "Gambia", "Georgia", "Ghana", "Granada", "Grecia", "Guatemala", "Guinea", "Guinea-Bisáu", "Guinea Ecuatorial", "Guyana",
    "Haití", "Honduras", "Hungría", "India", "Indonesia", "Irak", "Irán", "Irlanda", "Islandia", "Islas Marshall", "Islas Salomón", "Israel", "Italia", "Jamaica", "Japón", "Jordania",
    "Kazajistán", "Kenia", "Kirguistán", "Kiribati", "Kuwait", "Laos", "Lesoto", "Letonia", "Líbano", "Liberia", "Libia", "Liechtenstein", "Lituania", "Luxemburgo", "Madagascar", "Malasia",
    "Malaui", "Maldivas", "Malí", "Malta", "Marruecos", "Mauricio", "Mauritania", "México","Micronesia", "Moldavia", "Mónaco", "Mongolia", "Montenegro", "Mozambique", "Namibia", "Nauru",
    "Nepal", "Nicaragua", "Níger", "Nigeria", "Noruega", "Nueva Zelanda", "Omán", "Países Bajos","Pakistán", "Palaos", "Panamá", "Papúa Nueva Guinea", "Paraguay", "Perú", "Polonia", "Portugal",
    "Reino Unido", "República Centroafricana", "República Checa", "República del Congo", "República Democrática del Congo", "República Dominicana", "Ruanda", "Rumanía","Rusia", "Samoa", "San Cristóbal y Nieves", "San Marino", "San Vicente y las Granadinas",
    "Santa Lucía", "Santo Tomé y Príncipe", "Senegal","Serbia", "Seychelles", "Sierra Leona", "Singapur", "Siria", "Somalia", "Sri Lanka", "Sudáfrica",
    "Sudán", "Sudán del Sur", "Suecia", "Suiza", "Surinam", "Tailandia", "Tanzania", "Tayikistán", "Timor Oriental", "Togo", "Tonga", "Trinidad y Tobago", "Túnez", "Turkmenistán", "Turquía", "Tuvalu",
    "Ucrania", "Uganda", "Uruguay", "Uzbekistán", "Vanuatu", "Venezuela", "Vietnam", "Yemen",
    "Yibuti", "Zambia", "Zimbabue"
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
    if (title.trim().isEmpty) return false;
    if (imagePath == null) return false;
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

  void onSubmit() {
    if (isFormValid()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Receta guardada con éxito'),
          actions: [
            TextButton(
              onPressed:() => Navigator.of(context).pushNamed('/home'),
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

  Future<void> _guardarReceta() async {
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
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(
        title: Text(
          widget.recetaEditar == null ? AppStrings.anadirNuevaReceta : AppStrings.editarReceta,
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
              child: Text(AppStrings.anadirImagen,
              style: TextStyle(
                fontSize: 20,
              )
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
                    imagePath == null //&& widget.recetaEditar?.imagenBase64 == null
                    ? const Center(
                        child: Text('+', style: TextStyle(fontSize: 40),
                        ),
                      )
                      : kIsWeb ? Image.network(
                        fit: BoxFit.fill,
                        imagePath!,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text("Error al cargar imagen web")),
                      )
                      
                      // Importante: La clase File ya está importada en el inicio del archivo
                      : Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // TÍTULO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            TextField(
              controller: titleController,
              onChanged: (val) => title = val,
              style: const TextStyle(
                fontSize: 22,       
              ),
            ),

            const SizedBox(height: 30),

            // INGREDIENTES DINÁMICOS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ingredientes:",
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18,),
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
                        ..selection= TextSelection.collapsed(offset: ing.nombre.length),
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
                        ..selection = TextSelection.collapsed(offset: ing.cantidad.length),
                        onChanged: (val) => ing.cantidad = val,
                        decoration: const InputDecoration(hintText: AppStrings.cantidadHint),
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
              child: Text("Pasos:",
              style: TextStyle(
               fontWeight: FontWeight.w600, fontSize: 18
              ),
              ),
            ),
            // ... (mapeo de pasos)
            ...steps.asMap().entries.map((entry) {
                int idx = entry.key;
                Paso step = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: ValueKey("step_desc_$idx"),
                          controller: TextEditingController(text: step.descripcion)
                            ..selection = TextSelection.collapsed(offset: step.descripcion.length),
                          onChanged: (val) => step.descripcion= val,
                          decoration: const InputDecoration(
                            hintText: 'Paso',
                          ),
                        ),
                      ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => removeStep(idx),
                      child: const Text('-'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
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

            const SizedBox(height: 50),

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
                    decoration: InputDecoration(
                      labelText: 'Alérgenos',
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
