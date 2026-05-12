import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:remy_recipes/screens/login_screen.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import '../services/recetas_service.dart';
import '../data/models/receta.dart';
import '../data/models/usuario.dart';
import 'DetalleRecetaPage.dart';
import 'package:remy_recipes/services/config.dart';
import 'package:flutter/material.dart';
import 'EditProfileScreen.dart';
import '../l10n/app_localizations.dart';

// =======================================================
//              PANTALLA DE PERFIL DE USUARIO
// =======================================================

class PerfilScreen extends StatefulWidget {
  final AuthService authService;
  final Usuario? usuarioAMostrar;
  final bool viewOnly;
  const PerfilScreen({
    super.key,
    required this.authService,
    this.usuarioAMostrar,
    this.viewOnly = false,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();

  late Usuario user;
  List<Receta> recetasGuardadas = []; // Recetas propias del usuario
  List<Receta> favoritos = []; // Lista simulada/pendiente de implementación
  List<String> personas = []; // Lista simulada/pendiente de implementación
  String currentView = "home"; // Vista activa en el menú inferior
  String hovered = ""; // Para efecto hover (más útil en web)

  @override
  void initState() {
    super.initState();
    logger.i('Inicializando pantalla de perfil'); // Log de inicio

    // Protección: si no hay usuario logueado → redirige a login
    if (widget.authService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    // Cargamos el usuario desde AuthService
    user = widget.usuarioAMostrar ?? widget.authService.currentUser!;

    // Cargamos las recetas del usuario
    _cargarRecetasGuardadas();
    //Cargamos las recetas favoritas
    _cargarFavoritos();
  }

  /// Carga las recetas propias del usuario (públicas + privadas)
  Future<void> _cargarRecetasGuardadas() async {
    logger.i('desde Profile 🧠 USUARIO ACTUAL ID: ${user.id}'); // Log de inicio
    logger.d(
      '🧠 TOKEN PERFIL: ${widget.authService.accessToken != null ? "Sí" : "No"}',
    ); // Debug

    if (widget.authService.accessToken == null) return;

    try {
      // Llamada al servicio (debería estar en recetas_service.dart)
      final recetas = await obtenerRecetasUsuario(
        widget.authService.accessToken!,
        user.id.toString(),
      );

      logger.i('📦 RECETAS RECIBIDAS: ${recetas.length}');

      setState(() {
        recetasGuardadas = recetas;
      });
    } catch (e) {
      logger.e("Error cargando recetas del usuario: $e");
    }
  }

  //Declaramos la función de cargar los favoritos del usuario
  Future<void> _cargarFavoritos() async {
    if (widget.viewOnly) return;
    if (widget.authService.accessToken == null) return;
    logger.i('INICIANDO CARGA DE FAVORITOS');
    try {
      final lista = await obtenerFavoritos(widget.authService.accessToken!);
      logger.i('FAVORITOS RECIBIDOS: ${lista.length}');
      setState(() {
        favoritos = lista;
      });

      logger.i('Favoritos actualizados: ${favoritos.length}');
    } catch (e) {
      logger.e("Error cargando favoritos: $e");
    }
  }

  // ==============================================
  //                ESTRUCTURA GENERAL
  // ==============================================

  @override
  Widget build(BuildContext context) {
    logger.i('Construyendo pantalla de perfil'); // Log de construcción
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFDEB887,
        ), // Color característico de la app
        elevation: 0, // Sin sombra para que se integre con la cabecera
        actions: widget.viewOnly
            ? null
            : [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      logger.i('Seleccionando editar perfil');
                      _editarPerfil();
                    } else if (value == 'cerrar') {
                      logger.i('Seleccionando cerrar sesión');
                      _cerrarSesion();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'editar',
                      child: Text(AppLocalizations.of(context)!.editarPerfil),
                    ),
                    PopupMenuItem<String>(
                      value: 'cerrar',
                      child: Text(AppLocalizations.of(context)!.cerrarSesion),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                ),
              ],
      ),
      body: Column(
        children: [
          // Cabecera con foto, nombre y descripción (sin el menú, que ahora está en AppBar)
          _buildHeader(),
          if (!widget.viewOnly) _buildMenuBar(),

          // Contenido dinámico según la vista seleccionada
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(
                255,
                192,
                187,
                181,
              ), // Fondo beige suave
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  //                  CABECERA PERFIL
  // ==============================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 360,
      color: const Color(0xFFDEB887), // Color característico de la app
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //tamaño del contenedor
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            //esto recorta la imagen en forma de circulo
            child: ClipOval(
              // URL del backend para obtener la foto de perfil
              //evita que flutter use la imagen en cache y fuerza a pedirla en el backend
              child: user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty
                ? Image.network(
                    '${ApiEndpoints.baseUrl}/${user.fotoPerfil!.replaceFirst('/', '')}?t=${DateTime.now().millisecondsSinceEpoch}',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      logger.w('Error cargando imagen de perfil');
                      return const Text("👤", style: TextStyle(fontSize: 55));
                    },
                  )
                : const Text("👤", style: TextStyle(fontSize: 55)),
            ),
          ),

          const SizedBox(height: 10),

          // Nombre de usuario
          Text(
            user.userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Text(
            AppLocalizations.of(context)!.descripcion,
            style: TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 4),

          // Caja de descripción
          Container(
            width: 260,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDEB887),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              user.descripcion ?? AppLocalizations.of(context)!.sinDescripcion,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================
  //               MENÚ INFERIOR (ICONOS)
  // ==============================================

  Widget _buildMenuBar() {
    return Container(
      height: 75,
      color: const Color.fromARGB(255, 141, 134, 134),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _menuButton(Icons.favorite, "favoritos"),
          _menuButton(Icons.bookmark, "guardados"),
          _menuButton(Icons.home, "home"),
          _menuButton(Icons.people, AppLocalizations.of(context)!.personas),
        ],
      ),
    );
  }

  /// Botón del menú con efecto hover (útil en web) y selección
  Widget _menuButton(IconData icon, String view) {
  bool isSelected = currentView == view;

  return MouseRegion(
    onEnter: (_) => setState(() => hovered = view),
    onExit: (_) => setState(() => hovered = ""),
    child: GestureDetector(
      onTap: () {
        setState(() => currentView = view);
        
        // ⚠️ AÑADIR ESTA LÍNEA:
        if (view == "favoritos") {
          _cargarFavoritos();
        }
      },
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
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    ),
  );
}

  // ==============================================
  //             CONTENIDO DINÁMICO
  // ==============================================

 Widget _buildContent() {
  switch (currentView) {
    case "favoritos":
      if (favoritos.isEmpty) {
        return Center(
          child: Text(
            AppLocalizations.of(context)!.noRecetasGuardadas,
            style: TextStyle(fontSize: 16),
          ),
        );
      }
      return widget.viewOnly
          ? _buildHome()
          : _buildFavoritosGrid();

    case "guardados":
      return _buildRecetasGuardadas();
    case "personas":
      return _buildListaEditable(
        titulo: "Personas",
        lista: personas,
        onAdd: () => _addToList(personas),
      );
    default:
      return _buildHome();
  }
}

  // ⚠️ NUEVA FUNCIÓN: Muestra los favoritos en cuadrícula
  Widget _buildFavoritosGrid() {
    if (favoritos.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noRecetasGuardadas,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final receta = favoritos[index];

        return GestureDetector(
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            logger.i('Click en favorito: ${receta.titulo} (ID: ${receta.id})');
            try {
              final recetaCompleta = await obtenerRecetaPorId(
                widget.authService.accessToken!,
                receta.id!,
              );
              logger.i('Receta completa cargada para detalle');

              Navigator.pop(context);

              final refrescar = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleRecetaPage(
                    receta: recetaCompleta,
                    authService: widget.authService,
                  ),
                ),
              );

              // ⚠️ IMPORTANTE: Refrescar favoritos si se eliminó algo
              if (refrescar == true) _cargarFavoritos();
            } catch (e, s) {
              Navigator.pop(context);
              logger.e("🔥 ERROR en onTap: $e");
              logger.d(s);
            }
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: receta.imagenUrl != null && receta.imagenUrl!.isNotEmpty
                    ? Image.network(
                        '${ApiEndpoints.baseUrl}/${receta.imagenUrl!.replaceFirst('/', '')}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      )
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

  /// Muestra las recetas propias del usuario en un grid
  Widget _buildRecetasGuardadas() {
    if (recetasGuardadas.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noRecetasGuardadas,
          style: TextStyle(fontSize: 16),
        ),
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

        return GestureDetector(
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            logger.i(
              'Click en receta guardada: ${receta.titulo} (ID: ${receta.id})',
            ); // Log de acción
            try {
              final recetaCompleta = await obtenerRecetaPorId(
                widget.authService.accessToken!,
                receta.id!,
              );
              Navigator.pop(context);
              logger.i('Receta completa cargada para detalle'); // Log de éxito

              final refrescar = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleRecetaPage(
                    receta: recetaCompleta,
                    authService: widget.authService,
                  ),
                ),
              );

              // Si se eliminó o modificó la receta → recargar lista
              if (refrescar == true) _cargarRecetasGuardadas();
            } catch (e, s) {
              Navigator.pop(context);
              logger.e("🔥 ERROR en onTap: $e");
              logger.d(s); //Debug adicional
            }
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: receta.imagenUrl != null && receta.imagenUrl!.isNotEmpty
                      ? Image.network(
                          '${ApiEndpoints.baseUrl}/${receta.imagenUrl!.replaceFirst(RegExp(r'^/'), '')}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        )
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
    return Center(
      child: Text(
        AppLocalizations.of(context)!.vistaPrincipalPerfil,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  /// Lista editable genérica (usada para favoritos y personas - aún simulada)
  Widget _buildListaEditable({
    required String titulo,
    required List<String> lista,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            logger.i('Agregando elemento a lista: $titulo'); // Log de acción
            onAdd();
          },
          child: Text(AppLocalizations.of(context)!.anadirElemento),
        ),
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
                      logger.i(
                        'Eliminando elemento de lista: $titulo',
                      ); // Log de acción
                      setState(() => lista.removeAt(index));
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addToList(List<String> lista) {
    setState(() {
      if (user.descripcion != null && user.descripcion!.trim().isNotEmpty) {
        logger.i('Agregando descripción a lista'); // Log de acción
        lista.add(user.descripcion!);
      }
    });
  }

  // ==============================================
  //               ACCIONES PENDIENTES
  // ==============================================

  /*void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.abrirSelectorImagen)),
    );
    // Aquí debería abrir image_picker + subir al backend
  }*/

  void _editarPerfil() {
    if (widget.viewOnly) return;
    logger.i('Navegando a pantalla de edición de perfil'); // Log de navegación
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(authService: widget.authService),
      ),
    ).then((result) {
      if (result == true) {
        // Después de editar, refrescar el perfil
        logger.i('Regresando de edición - Refrescando perfil'); // Log de acción
        widget.authService.fetchProfile(int.parse(user.id)).then((_) {
          setState(() {
            user = widget.authService.currentUser!;
          });
        });
      }
    });
  }

  void _cerrarSesion() {
    if (widget.viewOnly) return;
    logger.i(
      'Cerrando sesión - Llamando a logout y navegando a login',
    ); // Log de acción
    // Llama al logout del AuthService
    widget.authService.logout();
    // Navega a la pantalla de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(authService: widget.authService),
      ),
    );
  }
}
