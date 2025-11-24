import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
const String _baseUrl = 'http://127.0.0.1:8000';



// DESPUES de la Seccion 4 y antes de la Seccion 5 (o donde desees ubicarla)
// ==========================================================================
// 4.5. PANTALLA DE INICIO (Dummy)
// ==========================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario',
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887), // BurlyWood
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// Barra superior
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              

              const SizedBox(height: 10),

              /// Logo
              SizedBox(
                width: 320,
                height: 300,
                child: Image.asset(
                  "assets/logosinfondoBien.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),
 ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add_recipe');
              },
              child: const Text('+'),
            ),
              /// Grid de recetas
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                
                children: const [
                  RecipeButton(image: "assets/sopa.webp", title: "Sopa"),
                  RecipeButton(image: "assets/pizza.webp", title: "Pizza"),
                  RecipeButton(image: "assets/tortilla.webp", title: "Tortilla de patata"),
                  RecipeButton(image: "assets/Aborrajado.webp", title: "Aborrajado"),
                  RecipeButton(image: "assets/carne.webp", title: "Carne"),
                  RecipeButton(image: "assets/perreteCalentito.webp", title: "Hot Dog"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}