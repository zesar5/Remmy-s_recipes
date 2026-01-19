import 'dart:convert';
import '../../services/recetas_service.dart';
import 'package:flutter/material.dart';
import 'package:remy_recipes/models/receta.dart';
import '../Profile/Profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../recipes/recipes_form_page.dart';
import '../../services/auth_service.dart';
import '../RecetaPage/DetalleRecetaPage.dart';
import '../../services/config.dart';
import '../../constants/app_strings.dart';

// =======================================================
//                  PANTALLA PRINCIPAL (HOME)
// =======================================================

/// Wrapper stateless que solo pasa el AuthService a la pantalla real
class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainPage(authService: authService);
  }
}

/// Pantalla principal con estado (donde ocurre toda la lógica)
class MainPage extends StatefulWidget {
  final AuthService authService;

  const MainPage({super.key, required this.authService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Lista de recetas mostradas en el grid (versión ligera para home)
  List<Receta> recipes = [];

  // Controla si estamos cargando datos
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes(); // Carga las recetas al iniciar la pantalla
  }

  void _openSearchSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_){
        return DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController){
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Lengueta superior
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    //barra de búsqueda
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar receta...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _combo("País origen", ["España", "Italia", "México"]),
                        _combo("Estaciones", ["Verano", "Otoño", "Invierno"]),
                        _combo("Duración", ["30 min", "60 min", "90 min"]),
                        _combo("Alérgenos", ["Gluten", "Lácteos", "Frutos secos"]),
                        SizedBox(
                          width: double.infinity,
                          child: _combo(
                            "Grupo alimenticio",
                            ["Carne", "Pescado", "Vegetariano"],
                          )
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: (){
                        //Aquí se lanzaría la búsqueda real
                        Navigator.pop(context);
                      },
                      child: const Text("Aplicar filtros"),
                    ),
                  ],
                )
              )
            );
          },
        );
      },
    );
  }
  Widget _combo(String label, List<String> items){
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
              ),
          ),
          items: items
          .map(
            (e) => DropdownMenuItem(value:e,
             child: Text(e),
             ),
            )
            .toList(),
            onChanged: (value){},
      ),
    );
  }

  /// Obtiene las recetas para la home (versión ligera: solo id, título e imagen)
  /// Actualmente usa http directo → sería mejor usar RecetasService
  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.homeRecetas),
      );

      print(response.body); // ← Útil para depuración

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        recipes = data.map((e) => Receta.fromHomeJson(e as Map<String, dynamic>)).toList();

        setState(() {
          // Aquí hay un error en el código original:
          // Primero usa fromHomeJson (correcto), pero luego sobrescribe con fromJson (incorrecto)
          // La versión corregida debería ser solo una de las dos
          recipes = data.map((e) => Receta.fromJson(e)).toList();
          loading = false;
        });

        print('RECIPES LENGTH: ${recipes.length}');
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error cargando recetas: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color de fondo cálido (típico tema cocina/recetas)
      backgroundColor: const Color(0xFFDEB887),

      // Botón flotante para crear nueva receta
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        onPressed: () {
          print('TOKEN antes de navegar: ${widget.authService.accessToken}');

          // Navega a formulario de creación de receta
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeFormPage(
                token:
                    widget.authService.accessToken!, // ← Asume que no es null
              ),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior: menú + búsqueda + perfil
              _buildTopBar(context),

              const SizedBox(height: 10),

              // Sección del logo y título de la app
              Column(
                children: [
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Alegreya',
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Logo centrado y escalado
                  Center(
                    child: Transform.scale(
                      scale: 1.7,
                      child: SizedBox(
                        width: 260,
                        height: 240,
                        child: Image.asset(
                          "assets/logosinfondoBien.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Título de la sección de recetas
              const Text(
                AppStrings.recetas,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Área principal: grid de recetas
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : recipes.isEmpty
                    ? const Center(child: Text(AppStrings.noHayRecetas))
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  250, // tamaño máximo de cada tarjeta
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85, // proporción altura/ancho
                            ),
                        itemCount: recipes.length,
                        itemBuilder: (_, i) {
                          final Receta r = recipes[i];
                          return RecipeButton(
                            recipe: r,
                            authService: widget.authService,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra superior con iconos: menú, búsqueda y perfil
  Row _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _topIcon(Icons.menu),
        Row(
          children: [
            _topIcon(Icons.search,
            onTap: (){
              _openSearchSheet(context);
            }),
            const SizedBox(width: 5),

            // Icono de perfil → navega solo si está logueado
            _topIcon(
              Icons.person,
              onTap: () {
                if (widget.authService.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.debesIniciarSesion)),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PerfilScreen(authService: widget.authService),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Widget reutilizable para los iconos de la barra superior
  Widget _topIcon(IconData icon, {VoidCallback? onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.8),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onTap ?? () {},
      ),
    );
  }
}

// =======================================================
//         TARJETA DE RECETA EN EL GRID (HOME)
// =======================================================

class RecipeButton extends StatelessWidget {
  final Receta recipe;
  final AuthService authService;

  const RecipeButton({
    super.key,
    required this.recipe,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    // Decodificamos la imagen base64 para mostrarla
    Uint8List? imageBytes;
    final String? base64String = recipe.imagenBase64;

    if (base64String != null && base64String.isNotEmpty) {
      try {
        // Quitamos el prefijo "data:image/...;base64," y decodificamos
        final base64Image = base64String.split(',').last;
        imageBytes = base64Decode(base64Image);
      } catch (e) {
        print('ERROR DECODING IMAGE: $e');
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        print("🖱️ Click en receta con id: ${recipe.id}");

        try {
          // Carga la receta completa (detalle) desde el backend
          final recetaCompleta = await obtenerRecetaPublicaPorId(recipe.id!);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleRecetaPage(
                receta: recetaCompleta,
                authService: authService,
              ),
            ),
          );
        } catch (e) {
          print("🔥 ERROR al cargar receta pública: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.errorCargarReceta)),
          );
        }
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Imagen ocupa la mayor parte de la tarjeta
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),

            // Título de la receta debajo
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
