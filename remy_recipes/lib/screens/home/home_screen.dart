
import 'package:flutter/material.dart';
import '../Profile/Profile_screen.dart';

const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';



// DESPUES de la Seccion 4 y antes de la Seccion 5 (o donde desees ubicarla)
// ==========================================================================
// 4.5. PANTALLA DE INICIO (Dummy)
// ==========================================================================

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainPage();
  }
}

class MainPage extends StatelessWidget {
   MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade800,
        onPressed: () => Navigator.of(context).pushNamed('/add_recipe'),
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
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _recipes.length,
                  itemBuilder: (_, i) {
                    final r = _recipes[i];
                    return RecipeButton(image: r.image, title: r.title);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen()),
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

class Recipe {
  final String image;
  final String title;
  const Recipe(this.image, this.title);
}

const List<Recipe> _recipes = [
  Recipe("assets/sopa.png", "Sopa"),
  Recipe("assets/pizza.png", "Pizza"),
  Recipe("assets/tortilla.png", "Tortilla de patata"),
  Recipe("assets/Aborrajado.png", "Aborrajado"),
  Recipe("assets/carne.png", "Carne"),
  Recipe("assets/perreteCalentito.png", "Hot Dog"),
];


// ★ Nuevo RecipeButton mejorado
class RecipeButton extends StatelessWidget {
  final String image;
  final String title;

  const RecipeButton({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}