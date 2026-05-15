import 'dart:convert';
import '../../services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../utils/image_url_helper.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Usuario> usuarios = [];
  bool isLoading = true;
  late SessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _sessionManager = SessionManager();
    fetchUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Usuario> get filteredUsuarios {
    if (_searchQuery.isEmpty) return usuarios;
    final query = _searchQuery.toLowerCase();
    return usuarios.where((u) => u.userName.toLowerCase().contains(query)).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
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
          : Column(
              children: [
                Container(
                  color: const Color(0xFFDEB887),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar usuario...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredUsuarios.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No hay usuarios para mostrar'
                                : 'No se encontró ningún usuario',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredUsuarios.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsuarios[index];

                            final fotoUrl = user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                                ? ImageUrlHelper.buildImageUrl(user.fotoUrl!)
                                : ImageUrlHelper.buildImageUrl('/usuarios/foto/${user.id}');
                            final ImageProvider<Object> avatarImage = user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty
                                ? (() {
                                    try {
                                      final base64String = user.fotoPerfil!.replaceFirst(RegExp(r'data:image/\w+;base64,'), '');
                                      return MemoryImage(base64Decode(base64String)) as ImageProvider<Object>;
                                    } catch (_) {
                                      return NetworkImage(fotoUrl) as ImageProvider<Object>;
                                    }
                                  })()
                                : NetworkImage(fotoUrl) as ImageProvider<Object>;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey.shade300,
                                  child: ClipOval(
                                    child: Image(
                                      image: avatarImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                title: Text(user.userName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user.pais != null && user.pais!.isNotEmpty)
                                      Text('${user.pais!} • ${user.email}'),
                                    if (user.pais == null || user.pais!.isEmpty)
                                      Text(user.email),
                                    if (user.descripcion != null && user.descripcion!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          user.descripcion!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  logger.i("Abriendo perfil de ${user.userName}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PerfilScreen(
                                        authService: widget.authService,
                                        usuarioAMostrar: user,
                                        viewOnly: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
