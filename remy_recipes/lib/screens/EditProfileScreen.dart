import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:remy_recipes/main.dart';
import '../services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

import '../data/constants/app_strings.dart';
import 'package:logger/logger.dart';
import 'Profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final AuthService authService;

  const EditProfileScreen({super.key, required this.authService});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController descripcionController;
  File? imagenPerfil;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    logger.i('Inicializando pantalla de edición de perfil'); // Log de inicio
    final user = widget.authService.currentUser!;
    nameController = TextEditingController(text: user.userName);
    descripcionController = TextEditingController(text: user.descripcion ?? '');
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
        const SnackBar(
          content: Text('Necesitamos permiso para acceder a tus fotos'),
        ),
      );
      return false;
    }
    if (status.isPermanentlyDenied) {
      logger.e("permiso denegado permanentemente");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'permiso de fotos bloqueado, activalo en ajustes.',
          ),
          action: SnackBarAction(label: 'Ajustes', onPressed: openAppSettings),
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
      setState(() => imagenPerfil = File(picked.path));
      logger.i('Imagen seleccionada'); // Log de éxito
    } else {
      logger.w('usuario cancelo la seleccion de imagen');
    }
  }

  Future<void> guardarCambios() async {
    logger.i('Guardando cambios de perfil'); // Log de inicio
    String? base64Image;
    if (imagenPerfil != null) {
      final bytes = await imagenPerfil!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
    }

    try {
      // Asumir que AuthService tiene un método updateProfile (agregarlo si no existe)
      await widget.authService.updateProfile(
        nombreUsuario: nameController.text.trim(),
        descripcion: descripcionController.text.trim(),
        fotoPerfil: base64Image,
      );
      logger.i('Perfil actualizado exitosamente'); // Log de éxito
      Navigator.pop(context, true); // Regresar a PerfilScreen
    } catch (e) {
      logger.e('Error actualizando perfil: $e'); // Log de error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: guardarCambios),
        ],
      ),
      body: Padding(
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
                backgroundImage: imagenPerfil != null
                    ? FileImage(imagenPerfil!)
                    : (widget.authService.currentUser!.fotoPerfil != null
                          ? MemoryImage(
                              base64Decode(
                                widget.authService.currentUser!.fotoPerfil!,
                              ),
                            )
                          : null),
                child:
                    imagenPerfil == null &&
                        widget.authService.currentUser!.fotoPerfil == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Nombre
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            const SizedBox(height: 20),

            // Descripción
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
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
