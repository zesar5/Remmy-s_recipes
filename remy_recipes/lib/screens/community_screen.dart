import 'dart:math';
import 'dart:convert';
import '../../services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profile_screen.dart';
import '../services/auth_service.dart';
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
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
    authService = widget.authService;
  }

  Future<void> fetchUsuarios() async {
    final response = await http.get(Uri.parse(ApiEndpoints.comunidad));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        usuarios = data.map((e) => Usuario.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar usuarios");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      appBar: AppBar(title: Text("Remmy's Recipes"), leading: BackButton()),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final user = usuarios[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,

                    backgroundImage:
                        user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty
                        ? NetworkImage(user.fotoPerfil!)
                        : null,

                    child: (user.fotoPerfil == null || user.fotoPerfil!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.userName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PerfilScreen(
                          authService: widget.authService,
                          usuarioAMostrar: user, // usuario de la lista
                          viewOnly: true, // modo solo visualización
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
