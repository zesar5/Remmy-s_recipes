import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:remy_recipes/models/receta.dart';
import '../Profile/Profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../recipes/recipes_form_page.dart';
import '../../services/auth_service.dart';

const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';



// DESPUES de la Seccion 4 y antes de la Seccion 5 (o donde desees ubicarla)
// ==========================================================================
// 4.5. PANTALLA DE INICIO (Dummy)
// ==========================================================================

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainPage(authService: authService);
  }
}

class MainPage extends StatefulWidget {
  final AuthService authService;

  const MainPage({
    super.key,
    required this.authService,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Receta> recipes = [];
  bool loading = true;
  //widget.authService

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recetas/?rangoInicio=1&rangoFin=4'),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        recipes = data.map((e) => Receta.fromJson(e as Map<String, dynamic>)).toList();

        setState(() {
          recipes = data.map((e) => Receta.fromJson(e)).toList();
          loading = false;
        });
        print('RECIPES LENGTH: ${recipes.length}');
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        onPressed: () {
          print('TOKEN antes de navegar a RecipeFormPage: ${widget.authService.accessToken}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeFormPage(
              token: widget.authService.accessToken!,
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
              
              // ★ Barra superior
              _buildTopBar(context),

              const SizedBox(height: 10),
              
              // ★ Logo centrado
             Column(
              children: [
                // Título de la app
                const Text(
                  "Remmy's Recipes",
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

                

                // Logo escalado
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

              // ★ Título de sección
              const Text(
                
                "Recetas",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ★ Grid expandida y limpia
              Expanded(
                child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : recipes.isEmpty
                    ? const Center(child: Text('No hay recetas'))
                    : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (_, i) {
                        final Receta r = recipes[i];
                        return RecipeButton(recipe: r);
                      },
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildTopBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _topIcon(Icons.menu),
      Row(
        children: [
          _topIcon(Icons.search),
          const SizedBox(width: 5),
          
          // ← AQUI SE NAVEGA AL PERFIL
          _topIcon(
            Icons.person,
            onTap: () {
              if (widget.authService.currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Debes iniciar sesión")),
                );
                return;
              }
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen(
                  authService: widget.authService,
                )),
              );
            },
          ),
        ],
      ),
    ],
  );
}

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

class Receta {
  final String titulo;
  final String imagenBase64;

  Receta({required this.titulo, required this.imagenBase64});

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      titulo: json['titulo'] as String,
      imagenBase64: json['imagenBase64'] ?? '', // si llega null, ponemos ''
    );
  }
}


// =======================================================
// RecipeButton que usa Base64
// =======================================================
class RecipeButton extends StatelessWidget {
  final Receta recipe;

  const RecipeButton({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (recipe.imagenBase64.isNotEmpty) {
      try {
        final base64Image = recipe.imagenBase64.split(',').last;
        imageBytes = base64Decode(base64Image);
      } catch (e) {
      print('ERROR DECODING IMAGE: $e');
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
