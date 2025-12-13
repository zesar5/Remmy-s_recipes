import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import '../home/home_screen.dart';
//const String _baseUrl = 'http://10.0.2.2:8000';
const String _baseUrl = 'http://localhost:8000';


void main() {
  runApp(const MaterialApp(
    home: PerfilScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Simulación de BD
  String username = "USERNAME DESDE BD";
  String descripcion = "Aquí aparecerá la descripción del usuario proveniente de la BD.";
  String hovered = "";

  // Listas internas (favoritos, guardados, personas)
  List<String> favoritos = [];
  List<String> guardados = [];
  List<String> personas = [];

  // Menú actual
  String currentView = "home";

  // -----------------------------
  // UI PRINCIPAL
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER (altura fija)
          Container(
            width: double.infinity,
            height: 360,
            color: const Color(0xFFDEB887),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // FOTO CLICKABLE
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
                    child: const Text("👤", style: TextStyle(fontSize: 55)),
                  ),
                ),
                const SizedBox(height: 10),

                // USERNAME
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // BOTÓN EDITAR PERFIL (REDONDEADO)
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

                const Text("Descripción:",
                    style: TextStyle(fontSize: 15)),

                const SizedBox(height: 4),

                // DESCRIPCIÓN SOLO MOSTRAR
                Container(
                  width: 260,
                  height: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:const Color(0xFFDEB887),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    descripcion,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------
          // BARRA DE BOTONES ARRIBA
          // -----------------------------
          Container(
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
          ),

          // -----------------------------
          // CONTENIDO DINÁMICO
          // -----------------------------
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

  // -----------------------------
  // BOTÓN DEL MENÚ
  // -----------------------------
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

  // -----------------------------
  // CONTENIDO SEGÚN SECCIÓN
  // -----------------------------
  Widget _buildContent() {
    switch (currentView) {
      case "favoritos":
        return _buildListaEditable(
            titulo: "Favoritos",
            lista: favoritos,
            onAdd: () => _addToList(favoritos));
      case "guardados":
        return _buildListaEditable(
            titulo: "Guardados",
            lista: guardados,
            onAdd: () => _addToList(guardados));
      case "personas":
        return _buildListaEditable(
            titulo: "Personas",
            lista: personas,
            onAdd: () => _addToList(personas));
      default:
        return _buildHome();
    }
  }

  // -----------------------------
  // HOME
  // -----------------------------
  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Inicio",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(
          "Esta es la vista principal. Usa los botones de arriba para navegar "
          "entre Favoritos, Guardados y Personas.",
          style: TextStyle(fontSize: 15),
        )
      ],
    );
  }

  // -----------------------------
  // LISTAS (Favoritos / Guardados / Personas)
  // -----------------------------
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

        // Añadir
        ElevatedButton(
            onPressed: onAdd,
            child: const Text("Añadir elemento desde descripción")),

        const SizedBox(height: 10),

        // Lista
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

  // -----------------------------
  // AÑADIR DESDE DESCRIPCIÓN
  // -----------------------------
  void _addToList(List<String> lista) {
    setState(() {
      if (descripcion.trim().isNotEmpty) {
        lista.add(descripcion);
      }
    });
  }

  // -----------------------------
  // FUNCIÓN CAMBIAR FOTO
  // -----------------------------
  void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aquí abrirías selector de imagen")),
    );
  }

  // -----------------------------
  // EDITAR PERFIL
  // -----------------------------
  void _editarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aquí abrirías edición de perfil")),
    );
  }
}