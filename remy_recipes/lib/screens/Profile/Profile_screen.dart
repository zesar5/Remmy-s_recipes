import 'package:remy_recipes/main.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/recetas_service.dart';
import '../../models/receta.dart';
import '../../models/usuario.dart';
import '../RecetaPage/DetalleRecetaPage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import 'package:remy_recipes/screens/home/home_screen.dart' hide Receta;
const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';


class PerfilScreen extends StatefulWidget {
  final AuthService authService;

  const PerfilScreen({super.key, required this.authService});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  late Usuario user;
  List<Receta> recetasGuardadas = [];
  List<String> favoritos = [];
  List<String> personas = [];

  String currentView = "home";
  String hovered = "";
  @override
void initState() {
  super.initState();
  if (widget.authService.currentUser == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
    return;
  }

  user = widget.authService.currentUser!;
  _cargarRecetasGuardadas();
}

Future<void> _cargarRecetasGuardadas() async {
    print('desde Profile 🧠 USUARIO ACTUAL ID: ${user.id}');
    print('🧠 TOKEN PERFIL: ${widget.authService.accessToken}');
    if (widget.authService.accessToken == null) return;
    try {
      final recetas = await obtenerRecetasUsuario(
        widget.authService.accessToken!, 
        user.id.toString()
      );
      print('📦 RECETAS RECIBIDAS: ${recetas.length}');
      setState(() {
        recetasGuardadas = recetas;
      });
    } catch (e) {
      print("Error cargando recetas del usuario SOY INUTIL: $e");
    }
  }

  // -----------------------------
  // UI PRINCIPAL
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildMenuBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 192, 187, 181),
              child: _buildContent(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 360,
      color: const Color(0xFFDEB887),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _cambiarFoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty
                  ? ClipOval(
                      child: Image.memory(
                        base64Decode(user.fotoPerfil!),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Text(
                      "👤",
                      style: TextStyle(fontSize: 55),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(user.userName,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: _editarPerfil,
              child: const Text(
                "Editar perfil",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Descripción:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Container(
            width: 260,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDEB887),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(user.descripcion ?? "Sin descripción",
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 75,
      color: const Color.fromARGB(255, 141, 134, 134),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuButton("❤", "favoritos"),
          _menuButton("🔖", "guardados"),
          _menuButton("🏠", "home"),
          _menuButton("👥", "personas"),
        ],
      ),
    );
  }
  Widget _menuButton(String icon, String view) {
    bool isSelected = currentView == view;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = view),
      onExit: (_) => setState(() => hovered = ""),
      child: GestureDetector(
        onTap: () => setState(() => currentView = view),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 85,
          height: 55,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF575757)
                : (hovered == view
                    ? Colors.white.withOpacity(0.15)
                    : const Color(0xFF3A3A3A)),
            borderRadius: BorderRadius.circular(10),
            boxShadow: hovered == view
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 26, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (currentView) {
      case "favoritos":
        return _buildListaEditable(
            titulo: "Favoritos",
            lista: favoritos,
            onAdd: () => _addToList(favoritos));
      case "guardados":
        return _buildRecetasGuardadas();
      case "personas":
        return _buildListaEditable(
            titulo: "Personas",
            lista: personas,
            onAdd: () => _addToList(personas));
      default:
        return _buildHome();
    }
  }

  Widget _buildRecetasGuardadas() {
    if (recetasGuardadas.isEmpty) {
      return const Center(
        child: Text('No tienes recetas guardadas',
            style: TextStyle(fontSize: 16)),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: recetasGuardadas.length,
      itemBuilder: (context, index) {
        final receta = recetasGuardadas[index];
        Uint8List? imageBytes;
        final String? base64String = receta.imagenBase64;
          if (base64String != null && base64String.contains(',')) {
            try {
              final base64Image = base64String.split(',').last;
              if (base64Image.isNotEmpty) {
                imageBytes = base64Decode(base64Image);
              }
            } catch (e) {
              print('ERROR DECODING IMAGE: $e');
            }
          }

        return GestureDetector(
          onTap: () async {
            try {
              print("🖱️ Tap detectado en receta ${receta.id}");
              print("🔄 token de DetalleRecetaPage: ${widget.authService}");
              final recetaCompleta = await obtenerRecetaPorId(
                widget.authService.accessToken!,
                receta.id!,
              );
              print("📦 Receta completa recibida: $recetaCompleta");

              final refrescar = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleRecetaPage(
                    receta: recetaCompleta,
                    authService: widget.authService),
                ),
              );
              print("🔄 Regresó de DetalleRecetaPage: $refrescar");
              if (refrescar == true) _cargarRecetasGuardadas();
            } catch (e, s) {
            print("🔥 ERROR en onTap: $e");
            print(s);
            }
          },
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    receta.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHome() {
    return const Center(
      child: Text(
        "Vista principal del perfil.",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildListaEditable({
    required String titulo,
    required List<String> lista,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: onAdd,
            child: const Text("Añadir elemento desde descripción")),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(lista[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        lista.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _addToList(List<String> lista) {
    setState(() {
      if (user.descripcion != null && user.descripcion!.trim().isNotEmpty) {
        lista.add(user.descripcion!);
      }
    });
  }

  void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aquí abrirías selector de imagen")));
  }

  void _editarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aquí abrirías edición de perfil")));
  }
}
