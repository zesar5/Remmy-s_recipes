import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:remy_recipes/screens/login_screen.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import '../services/recetas_service.dart';
import '../data/models/receta.dart';
import '../data/models/usuario.dart';
import 'DetalleRecetaPage.dart';
import 'dart:convert';
import 'package:remy_recipes/services/config.dart';
import 'package:flutter/material.dart';
import '../data/constants/app_strings.dart';
import 'package:logger/logger.dart';

// =======================================================
//              PANTALLA DE PERFIL DE USUARIO
// =======================================================

class PerfilScreen extends StatefulWidget {
  final AuthService authService;

  const PerfilScreen({super.key, required this.authService});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();

  late Usuario user;
  List<Receta> recetasGuardadas = []; // Recetas propias del usuario
  List<String> favoritos = []; // Lista simulada/pendiente de implementación
  List<String> personas = []; // Lista simulada/pendiente de implementación
  String currentView = "home"; // Vista activa en el menú inferior
  String hovered = ""; // Para efecto hover (más útil en web)

  @override
  void initState() {
    super.initState();
     logger.i('Inicializando pantalla de perfil');  // Log de inicio

    // Protección: si no hay usuario logueado → redirige a login
    if (widget.authService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    // Cargamos el usuario desde AuthService
    user = widget.authService.currentUser!;

    // Intentamos cargar las recetas del usuario
    _cargarRecetasGuardadas();
  }

  // ────────────────────────────────────────────────
  //     FUNCIÓN QUE SE EJECUTA AL TOCAR LA FOTO
  // ────────────────────────────────────────────────
  Future<void> _cambiarFoto() async {
    logger.i('Iniciando cambio de foto de perfil');  // Log de acción
    //abre galeria del dispositivo y permite al usuario elegir una
    // image_picker devuelve un XFile (o null si el usuario cancela)
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    //si el usuario ha seleccionado una imagen
    if (image != null) {
      logger.i('Imagen seleccionada para subir');  // Log de éxito
      // Convertimos XFile a File para poder enviarlo por HTTP
      File file = File(image.path);
      // Llama a la función de subida con el token del servicio de autenticación
      // Le pasamos:
      //  - el archivo seleccionado
      //  - el token JWT del usuario logueado
      await _uploadProfilePic(file, widget.authService.accessToken!);
    } else {
      //el usuario cancelo la seleccion de imagen
      logger.w("cancelastes la selección");// Advertencia
    }
  }

  // ────────────────────────────────────────────────
  //     FUNCIÓN QUE SUBE LA FOTO AL BACKEND
  // ────────────────────────────────────────────────
  Future<void> _uploadProfilePic(File imagenSeleccionada, String token) async {
    logger.i('Iniciando subida de foto de perfil al backend');  // Log de inicio
    //obtenemos el ID del usuario actualmente autenticado
    //el id viene del login...
    final userId = widget.authService.currentUser!.id;
    // Creamos una petición HTTP de tipo multipart (necesaria para enviar archivos)
    var request = http.MultipartRequest(
      'POST',
      //URL del backend para subir la foto
      //el ID va en la ruta,y la seguridad la da el token
      Uri.parse('$baseUrl/usuarios/foto/$userId'),
    );

    // Añadimos el token JWT al header Authorization
    // El backend lo validará con authMiddleware
    request.headers['Authorization'] = 'Bearer $token';

    //AÑADIMOS EL ARCHIVO A LA PETICION
    //que debe llamarse igual que en el backend
    request.files.add(
      await http.MultipartFile.fromPath('profilePic', imagenSeleccionada.path),
    );
    //enviamos la peticion al backend
    var response = await request.send();
    //si el backend dice ok
    if (response.statusCode == 200) {
       logger.i('Foto de perfil actualizada exitosamente en backend');  // Log de éxito
      // Forzamos el rebuild del widget para que
      // Image.network vuelva a cargar la imagen
      setState(() {});
    } else {
      logger.e('Error al subir foto de perfil: Código ${response.statusCode}');  // Log de error
    }
  }

  /// Carga las recetas propias del usuario (públicas + privadas)
  Future<void> _cargarRecetasGuardadas() async {
    logger.i('desde Profile 🧠 USUARIO ACTUAL ID: ${user.id}');  // Log de inicio
    logger.d('🧠 TOKEN PERFIL: ${widget.authService.accessToken != null ? "Sí" : "No"}');  // Debug

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

  // ==============================================
  //                ESTRUCTURA GENERAL
  // ==============================================

  @override
  Widget build(BuildContext context) {
    logger.i('Construyendo pantalla de perfil');  // Log de construcción
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFDEB887,
        ), // Color característico de la app
        elevation: 0, // Sin sombra para que se integre con la cabecera
        actions: [
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
              const PopupMenuItem<String>(
                value: 'editar',
                child: Text('Editar perfil'),
              ),
              const PopupMenuItem<String>(
                value: 'cerrar',
                child: Text('Cerrar sesión'),
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

          // Barra de navegación inferior (menú de vistas)
          _buildMenuBar(),

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
          // ────────────────────────────────────────────────
          //     FOTO DE PERFIL (TOCAR PARA CAMBIAR)
          // ────────────────────────────────────────────────
          GestureDetector(
            //cuando toca foto se abre galeria
            onTap: () {
              logger.i('Click en foto de perfil - Iniciando cambio');  // Log de acción
              _cambiarFoto();
            },
            child: Container(
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
                child: Image.network(
                  '$baseUrl/usuarios/foto/${user.id}?t=${DateTime.now().millisecondsSinceEpoch}',

                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                     logger.w('Error cargando imagen de perfil - Mostrando placeholder');  // Advertencia
                    return const Text("👤", style: TextStyle(fontSize: 55));
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nombre de usuario
          Text(
            user.userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Text(AppStrings.descripcion, style: TextStyle(fontSize: 15)),

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
              user.descripcion ?? AppStrings.sinDescripcion,
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
          _menuButton("❤", AppStrings.favoritos),
          _menuButton("🔖", "guardados"),
          _menuButton("🏠", "home"),
          _menuButton("👥", AppStrings.personas),
        ],
      ),
    );
  }

  /// Botón del menú con efecto hover (útil en web) y selección
  Widget _menuButton(String icon, String view) {
    bool isSelected = currentView == view;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = view),
      onExit: (_) => setState(() => hovered = ""),
      child: GestureDetector(
         onTap: () {
          logger.i('Cambiando vista a: $view');  // Log de navegación
          setState(() => currentView = view);
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
          child: Text(
            icon,
            style: const TextStyle(fontSize: 26, color: Colors.white),
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
        return _buildListaEditable(
          titulo: "Favoritos",
          lista: favoritos,
          onAdd: () => _addToList(favoritos),
        );
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

  /// Muestra las recetas propias del usuario en un grid
  Widget _buildRecetasGuardadas() {
    if (recetasGuardadas.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.noRecetasGuardadas,
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
        Uint8List? imageBytes;

        final String? base64String = receta.imagenBase64;
        if (base64String != null && base64String.contains(',')) {
          try {
            final base64Image = base64String.split(',').last;
            if (base64Image.isNotEmpty) {
              imageBytes = base64Decode(base64Image);
            }
          } catch (e) {
            logger.e('Error decodificando imagen de receta ${receta.id}: $e');  // Log de error
          }
        }

         return GestureDetector(
          onTap: () async {
            logger.i('Click en receta guardada: ${receta.titulo} (ID: ${receta.id})');  // Log de acción
            try {
              final recetaCompleta = await obtenerRecetaPorId(
                widget.authService.accessToken!,
                receta.id!,
              );
              logger.i('Receta completa cargada para detalle');  // Log de éxito

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
              logger.e("🔥 ERROR en onTap: $e");
              logger.d(s);//Debug adicional
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
        AppStrings.vistaPrincipalPerfil,
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
            logger.i('Agregando elemento a lista: $titulo');  // Log de acción
            onAdd();
          },
          child: const Text(AppStrings.anadirElemento),
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
                      logger.i('Eliminando elemento de lista: $titulo');  // Log de acción
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
        logger.i('Agregando descripción a lista');  // Log de acción
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
     logger.i('Acción pendiente: Editar perfil - Mostrando SnackBar');  // Log de acción (indica que es pendiente)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.abrirEditarPerfil)));
    // Pendiente: pantalla de edición de perfil
  }

  void _cerrarSesion() {
     logger.i('Cerrando sesión - Llamando a logout y navegando a login');  // Log de acción
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
