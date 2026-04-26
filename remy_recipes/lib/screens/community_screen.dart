import 'dart:convert';
import '../../services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/session_manager.dart';
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
  late SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _sessionManager = SessionManager();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    try {
      // Obtener el token del AuthService
      final token = widget.authService.accessToken;
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      // Si hay token, agregarlo
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        logger.d('Enviando token en header Authorization');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.comunidad),
        headers: headers,
      ).timeout(
        const Duration(seconds: 50),
        onTimeout: () {
          logger.e('⏱️ Timeout al cargar usuarios de comunidad (50s)');
          throw Exception('Timeout: El servidor tardó demasiado en responder');
        },
      );

      logger.d('Respuesta comunidad - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        setState(() {
          // Limpiamos y llenamos la lista sin duplicados
          usuarios = data.map((e) => Usuario.fromJson(e)).toList();
          isLoading = false;
        });
        logger.i('✅ Usuarios de comunidad cargados: ${usuarios.length}');
      } else if (response.statusCode == 401) {
        // Sesión expirada
        logger.e('🔴 Error 401 en comunidad - Sesión expirada');
        await _sessionManager.handleSessionExpiration(response.statusCode, response.body);
        setState(() => isLoading = false);
      } else {
        logger.e("Error al cargar usuarios: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar usuarios: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e("Excepción al cargar usuarios: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

                // Construir la URL de la foto de forma flexible
                String? fotoUrl;
                if (user.fotoUrl != null) {
                  // Si viene la URL relativa del servidor, construir URL completa
                  fotoUrl = '${ApiEndpoints.baseUrl}${user.fotoUrl}?t=${DateTime.now().millisecondsSinceEpoch}';
                } else {
                  // Fallback: construir URL con el ID del usuario
                  fotoUrl = '${ApiEndpoints.baseUrl}/usuarios/foto/${user.id}?t=${DateTime.now().millisecondsSinceEpoch}';
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user.fotoPerfil != null
                          ? MemoryImage(base64Decode(user.fotoPerfil!.replaceFirst(RegExp(r'data:image/\w+;base64,'), '')))
                          : NetworkImage(fotoUrl),
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
