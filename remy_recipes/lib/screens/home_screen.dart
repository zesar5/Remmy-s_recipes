import 'dart:convert';
import 'package:remy_recipes/main.dart';

import '../services/recetas_service.dart';
import 'package:flutter/material.dart';
import 'package:remy_recipes/data/models/receta.dart';
import 'Profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'recipes_form_page.dart';
import '../services/auth_service.dart';
import 'DetalleRecetaPage.dart';
import '../services/config.dart';
import '../data/constants/app_strings.dart';
import 'package:logger/logger.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

// =======================================================
//                  PANTALLA PRINCIPAL (HOME)
// =======================================================

/// Wrapper stateless que solo pasa el AuthService a la pantalla real
class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainPage(authService: authService);
  }
}

/// Pantalla principal con estado (donde ocurre toda la lógica)
class MainPage extends StatefulWidget {
  final AuthService authService;

  const MainPage({super.key, required this.authService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Clave global para controlar el Scaffold (necesaria para abrir el drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de recetas mostradas en el grid (versión ligera para home)
  List<Receta> recipes = [];

  // Controla si estamos cargando datos
  bool loading = true;

  String? _textoBusqueda;
  String? _pais;
  String? _estacion;
  int? _duracion;
  String? _alergenos;

  @override
  void initState() {
    super.initState();
    logger.i('HomeScreen inicializada - Cargando recetas');
    fetchRecipes(); // Carga las recetas al iniciar la pantalla
  }

  // =======================
  // DIÁLOGO CAMBIO DE IDIOMA
  // =======================
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDEB887),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.aQueIdioma,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              // Botón Español
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStrings.colorFondo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  RemmyApp.setLocale(context, const Locale('es'));

                  logger.i("Idioma cambiado a Español");
                },
                child: Text(AppLocalizations.of(context)!.idiomaEspanyol),
              ),

              const SizedBox(height: 10),

              // Botón Inglés
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStrings.colorFondo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  RemmyApp.setLocale(context, const Locale('en'));

                  logger.i("Idioma cambiado a Inglés");
                },
                child: Text(AppLocalizations.of(context)!.idiomaIngles),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSearchSheet(BuildContext context) {
    logger.i('Abriendo hoja de búsqueda');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.25,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //Lengueta superior
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    //barra de búsqueda
                    TextField(
                      onChanged: (value) {
                        _textoBusqueda = value;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.buscarReceta,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _combo(AppLocalizations.of(context)!.pais, AppStrings.countries),
                        _combo(AppLocalizations.of(context)!.estacionLabel, AppStrings.seasons),
                        _combo(AppLocalizations.of(context)!.duracionLabel, [
                          "5 min",
                          "10 min",
                          "20 min",
                          "30 min",
                          "60 min",
                          "90 min",
                        ]),
                        _combo(AppLocalizations.of(context)!.alergenosLabel, AppStrings.allergens),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20, // 👈 más espacio arriba
                        bottom: 5, // 👈 menos espacio abajo
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStrings.colorFondo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _cargarRecetasPredeterminadas();
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.cargarRecetasPredeterminadas),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStrings.colorFondo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: () {
                        logger.i('Aplicando filtros de búsqueda');
                        //Aquí se lanzaría la búsqueda real
                        _aplicarFiltro();
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.aplicarFiltros),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _aplicarFiltro() async {
    logger.i('Iniciando aplicación de filtros');
    setState(() => loading = true);

    final recetasFiltradas = await recetaFiltrada(
      texto: _textoBusqueda,
      pais: _pais,
      estacion: _estacion,
      duracion: _duracion,
      alergenos: _alergenos,
      token: widget.authService.accessToken,
    );

    setState(() {
      recipes = recetasFiltradas;
      loading = false;

      _textoBusqueda = '';
      _pais = null;
      _estacion = null;
      _duracion = null;
      _alergenos = null;
    });
    logger.i(
      'Filtros aplicados - Recetas encontradas: ${recetasFiltradas.length}',
    );
  }

  Widget _combo(String tipo, List<String> opciones) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: tipo,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: opciones
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          setState(() {
            switch (tipo) {
              case 'País':
                _pais = value;
                break;
              case 'Estación':
                _estacion = value;
                break;
              case 'Duración (min)':
                _duracion = int.tryParse(value!.replaceAll(' min', ''));
                break;
              case 'Alérgenos':
                _alergenos = value;
                break;
            }
          });
        },
      ),
    );
  }

  /// Obtiene las recetas para la home (versión ligera: solo id, título e imagen)
  /// Actualmente usa http directo → sería mejor usar RecetasService
  Future<void> fetchRecipes() async {
    logger.i('Iniciando carga de recetas para home');
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.homeRecetas));
      logger.d('Respuesta de fetchRecipes - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        recipes = data
            .map((e) => Receta.fromHomeJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          // Aquí hay un error en el código original:
          // Primero usa fromHomeJson (correcto), pero luego sobrescribe con fromJson (incorrecto)
          // La versión corregida debería ser solo una de las dos
          recipes = data.map((e) => Receta.fromHomeJson(e)).toList();
          loading = false;
        });

        logger.i('RECETAS CARGADAS EXITOSAMENTE: ${recipes.length}');
      } else {
        logger.e('Error al cargar recetas: Status ${response.statusCode}');
        setState(() => loading = false);
      }
    } catch (e) {
      logger.e("Error cargando recetas: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Clave para controlar el drawer
      // Color de fondo cálido (típico tema cocina/recetas)
      backgroundColor: const Color(0xFFDEB887),

      // Drawer lateral (menú que se abre desde el lado izquierdo)
      drawer: Drawer(
        backgroundColor: Colors.white, // Color de fondo similar al de la app
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón Comunidad
                ListTile(
                  leading: const Icon(Icons.people),
                  title: Text(AppLocalizations.of(context)!.comunidad),
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer
                    logger.i("Ir a Comunidad");
                    // TODO: Navegar a pantalla comunidad
                  },
                ),

                const Divider(),

                // Botón Idioma
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.idioma),
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer
                    _showLanguageDialog(context);
                    logger.i("Cambiar idioma");
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // Botón flotante para crear nueva receta
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStrings.colorFondo,
        foregroundColor: Colors.white,
        onPressed: () {
          logger.i(
            'Navegando a formulario de nueva receta',
          ); // Log de navegación
          logger.d(
            'Token presente: ${widget.authService.accessToken != null ? "Sí" : "No"}',
          ); // Debug

          // Verificar si el usuario está logueado
          if (widget.authService.currentUser == null) {
            logger.w('Intento de crear receta sin usuario logueado');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.debesIniciarSesion,
                ),
              ),
            );
            return;
          }

          // Navega a formulario de creación de receta
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeFormPage(
                token: widget.authService.accessToken!,
              ),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior: menú + búsqueda + perfil
              _buildTopBar(context),

              const SizedBox(height: 10),

              // Sección del logo y título de la app
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.appName,
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

                  // Logo centrado y escalado
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

              // Título de la sección de recetas
              Text(
                AppLocalizations.of(context)!.recetas,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Área principal: grid de recetas
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : recipes.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context)!.noHayRecetas),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 10),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  250, // tamaño máximo de cada tarjeta
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85, // proporción altura/ancho
                            ),
                        itemCount: recipes.length,
                        itemBuilder: (_, i) {
                          final Receta r = recipes[i];
                          return RecipeButton(
                            recipe: r,
                            authService: widget.authService,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra superior con iconos: menú + búsqueda + perfil
  Row _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _topIcon(
          Icons.menu,
          onTap: () {
            _scaffoldKey.currentState?.openDrawer(); // Abre el drawer lateral
          },
        ),
        Row(
          children: [
            _topIcon(
              Icons.search,
              onTap: () {
                _openSearchSheet(context);
              },
            ),
            const SizedBox(width: 5),

            // Icono de perfil → navega solo si está logueado
            _topProfileAvatar(
              authService: widget.authService,

              onTap: () {
                if (widget.authService.currentUser == null) {
                  logger.w(
                    'Intento de acceder a perfil sin usuario logueado',
                  ); // Advertencia
                 showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDEB887),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)!.necesitasIniciarSesion,  // Título corregido
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              // Botón para ir a la página de iniciar sesión
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStrings.colorFondo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  // Navega a la pantalla de login (reemplaza 'LoginScreen' con el nombre real de tu pantalla de login si es diferente)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  LoginScreen(authService: widget.authService),
                    ),
                  );
                  logger.i("Navegando a pantalla de login");
                },
                child: Text(AppLocalizations.of(context)!.irPaginaIniciarSesion),  // Texto corregido
              ),

              const SizedBox(height: 10),

              // Botón para permanecer de invitado
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStrings.colorFondo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo y permanece en la pantalla
                  logger.i("Permaneciendo como invitado");
                },
                child: Text(AppLocalizations.of(context)!.permanecerInvitado),  // Texto corregido
              ),
            ],
          ),
        );
      },
    );
    return;
  }

                logger.i('Navegando a pantalla de perfil');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PerfilScreen(authService: widget.authService),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _cargarRecetasPredeterminadas() async {
    logger.i('Restaurando recetas predeterminadas');

    setState(() {
      loading = true;
    });

    await fetchRecipes();
  }

  Widget _topProfileAvatar({
    required AuthService authService,
    required VoidCallback onTap,
  }) {
    final user = authService.currentUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: ClipOval(
          child: user != null
              ? Image.network(
                  '${ApiEndpoints.baseUrl}/usuarios/foto/${user.id}?t=${DateTime.now().millisecondsSinceEpoch}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('👤', style: TextStyle(fontSize: 18)),
                    );
                  },
                )
              : const Center(child: Text('👤', style: TextStyle(fontSize: 18))),
        ),
      ),
    );
  }

  /// Widget reutilizable para los iconos de la barra superior
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

// =======================================================
//         TARJETA DE RECETA EN EL GRID (HOME)
// =======================================================

class RecipeButton extends StatelessWidget {
  final Receta recipe;
  final AuthService authService;

  const RecipeButton({
    super.key,
    required this.recipe,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    // Decodificamos la imagen base64 para mostrarla
    Uint8List? imageBytes;

    final String? base64String = recipe.imagenBase64;
    if (base64String != null && base64String.isNotEmpty) {
      try {
        final base64Image = base64String.contains(',')
            ? base64String.split(',').last
            : base64String;
        imageBytes = base64Decode(base64Image);
      } catch (e) {
        logger.e('Error decodificando imagen de receta ${recipe.id}: $e');
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        logger.i(
          '🖱️ Click en receta con id: ${recipe.titulo} (ID: ${recipe.id})',
        );

        try {
          // Carga la receta completa (detalle) desde el backend
          final recetaCompleta = await obtenerRecetaPublicaPorId(recipe.id!);
          logger.i('Receta completa cargada - Navegando a detalle');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleRecetaPage(
                receta: recetaCompleta,
                authService: authService,
              ),
            ),
          );
        } catch (e) {
          logger.e("🔥 ERROR al cargar receta pública: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorCargarReceta),
            ),
          );
        }
      },

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
          children: [
            // Imagen ocupa la mayor parte de la tarjeta
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),

            // Título de la receta debajo
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
