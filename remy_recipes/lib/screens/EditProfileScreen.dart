import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:remy_recipes/main.dart';
import '../services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../services/config.dart';
import '../data/constants/app_strings.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthService authService;

  const EditProfileScreen({super.key, required this.authService});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = false;
  late TextEditingController nameController;
  late TextEditingController descripcionController;
  String? selectedCountry;
  File? imagenPerfilFile;
  String? imagenPerfilUrl;
  final picker = ImagePicker();
  ImageProvider? avatarImage;

  @override
  void initState() {
    super.initState();

    // Log de inicio
    final user = widget.authService.currentUser!;
    nameController = TextEditingController(text: user.userName);
    descripcionController = TextEditingController(text: user.descripcion ?? '');
    selectedCountry = user.pais;

    if (user.fotoPerfil != null && user.fotoPerfil!.isNotEmpty) {
      avatarImage = NetworkImage(
        '${ApiEndpoints.baseUrl}${user.fotoPerfil!.startsWith('/') 
            ? user.fotoPerfil! 
            : '/${user.fotoPerfil!}'}?t=${DateTime.now().millisecondsSinceEpoch}',
      );
    } else {
      avatarImage = null;
    }
    logger.i('Inicializando pantalla de edición de perfil');
  }

  Future<bool> _checkPhotoPermisission() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      logger.i('permiso de fotos concedido');
      return true;
    }
    if (status.isDenied) {
      logger.w('permiso de fotos denegado');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.necesitamosPermisos),
        ),
      );
      return false;
    }
    if (status.isPermanentlyDenied) {
      logger.e("permiso denegado permanentemente");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.permisosFotosBloqueado),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.ajustes,
            onPressed: openAppSettings,
          ),
        ),
      );
      return false;
    }

    return false;
  }

  Future<void> seleccionarImagen() async {
    logger.i('Seleccionando nueva imagen de perfil'); // Log de acción

    final hashPermission = await _checkPhotoPermisission();
    if (!hashPermission) return;

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => imagenPerfilFile = File(picked.path));
      logger.i('Imagen seleccionada');
    } else {
      logger.w('usuario cancelo la seleccion de imagen');
    }
  }

  Future<void> guardarCambios() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    logger.i('Guardando cambios de perfil');

    try {

      if (imagenPerfilFile != null) {
        imagenPerfilUrl = await widget.authService.subirFotoPerfil(
          imagenPerfilFile!,
        );
      }
      await widget.authService.updateProfile(
        nombreUsuario: nameController.text.trim(),
        descripcion: descripcionController.text.trim(),
        fotoPerfil: imagenPerfilUrl,
        pais: selectedCountry,
      );

      logger.i('Perfil actualizado exitosamente');

      Navigator.pop(context, true);

    } catch (e) {

      logger.e('Error actualizando perfil: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.error}: $e',
          ),
        ),
      );

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i(
      'Construyendo interfaz de edición de perfil',
    ); // Log de construcción
    return Scaffold(
      backgroundColor: const Color(0xFFE6C18C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.editarPerfil,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Foto de perfil
                GestureDetector(
                  onTap: seleccionarImagen,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    child: ClipOval(
                      child: imagenPerfilFile != null
                          ? Image.file(
                              imagenPerfilFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : (avatarImage != null
                                ? Image(
                                    image: avatarImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.camera_alt, size: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nombreUsuario,
                  ),
                ),
                const SizedBox(height: 20),

                // Descripción
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    )!.descripcionSinPuntos,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // País
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: InputDecoration(labelText: AppStrings.pais),
                  items: AppStrings.countries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCountry = v),
                ),
              ],
            ),
          ),

          // Botón Guardar fijo abajo
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStrings.colorFondo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.editarPerfil,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    logger.i('Destruyendo pantalla de edición de perfil'); // Log de limpieza
    nameController.dispose();
    descripcionController.dispose();
    super.dispose();
  }
}
