import 'dart:convert';
import '../../services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'Profile_screen.dart';
import 'package:logger/logger.dart';
import 'package:remy_recipes/data/models/usuario.dart';

class ComunidadScreen extends StatefulWidget {
  final AuthService authService;

  const ComunidadScreen({super.key, required this.authService});

  @override
  State<ComunidadScreen> createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  final Logger logger = Logger();
  List<Usuario> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.comunidad));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        setState(() {
          // Limpiamos y llenamos la lista sin duplicados
          usuarios = data.map((e) => Usuario.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        logger.e("Error al cargar usuarios: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("Excepción al cargar usuarios: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(
        title: const Text("Remmy's Recipes"),
        backgroundColor: const Color(0xFFDEB887),
        leading: BackButton(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final user = usuarios[index];

                // Construimos la URL de la foto como en PerfilScreen
                final fotoUrl =
                    "${ApiEndpoints.baseUrl}/usuarios/foto/${user.id}?t=${DateTime.now().millisecondsSinceEpoch}";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: NetworkImage(fotoUrl),
                      onBackgroundImageError: (_, __) => null,
                      child: const Icon(Icons.person),
                    ),
                    title: Text(user.userName),
                    subtitle: user.descripcion != null
                        ? Text(user.descripcion!)
                        : null,
                    onTap: () {
                      logger.i("Abriendo perfil de ${user.userName}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PerfilScreen(
                            authService: widget.authService,
                            usuarioAMostrar: user,
                            viewOnly: true, // modo solo visualización
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
