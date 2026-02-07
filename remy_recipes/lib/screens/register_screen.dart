import 'package:remy_recipes/main.dart';

import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';

// ==========================================================================
//                PANTALLA DE REGISTRO DE USUARIO
// ==========================================================================

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto
  final name = TextEditingController();
  final correo = TextEditingController();
  final contrasenya = TextEditingController();
  final confirmarContrasenya = TextEditingController();
  final descripcion = TextEditingController();

  // Selecciones de dropdowns
  String? paisSeleccionado;
  int? anioSeleccionado;

  // Imagen de perfil seleccionada (local)
  File? imagenPerfil;

  final picker = ImagePicker();

  // Flags de error visual (bordes rojos + mensajes)
  bool errorName = false;
  bool errorCorreo = false;
  bool errorContrasenya = false;
  bool errorConfirmar = false;
  bool errorPais = false;
  bool errorAnio = false;

  String? errorCorreoMensaje; // Mensaje personalizado para correo

  List<String> paises = [
    "Afganistán", "Albania", "Alemania", "Andorra", "Angola", "Arabia Saudita",
    "Argentina", "Australia", "Austria", "Bélgica", "Bolivia", "Brasil",
    "Canadá", "Chile", "China", "Colombia", "Corea del Sur", "Costa Rica",
    "Cuba", "Dinamarca", "Ecuador", "Egipto", "El Salvador", "Eslovaquia",
    "Eslovenia", "España", "Estados Unidos", "Finlandia", "Francia", "Grecia",
    "Guatemala", "Haití", "Honduras", "Hungría", "India", "Indonesia", "Irak",
    "Irán", "Irlanda", "Islandia", "Italia", "Japón", "Jordania", "Kenia",
    "Letonia", "Líbano", "Libia", "Lituania", "Luxemburgo", "México", "Mónaco",
    "Mongolia", "Nepal", "Nicaragua", "Nigeria", "Noruega", "Países Bajos",
    "Panamá", "Paraguay", "Perú", "Polonia", "Portugal", "Reino Unido",
    "República Dominicana", "Rumania", "Rusia", "Senegal", "Serbia", "Suecia",
    "Suiza", "Tailandia", "Turquía", "Ucrania", "Uruguay", "Venezuela",
    "Vietnam"
  ];

  List<int> anios = [ for (int i = DateTime.now().year; i >= 1900; i--) i ];

  // ==============================================
  //               VALIDACIONES
  // ==============================================

  bool validarCorreo(String correo) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(correo);
  }

  bool validarContrasenyaFuerte(String c) {
    return c.length >= 8 &&
        c.contains(RegExp(r'[A-Z]')) &&
        c.contains(RegExp(r'[a-z]')) &&
        c.contains(RegExp(r'[0-9]')) &&
        c.contains(RegExp(r'[^A-Za-z0-9]'));
  }

  // ==============================================
  //           SELECCIÓN DE FOTO DE PERFIL
  // ==============================================

  Future<void> seleccionarImagen() async {
    logger.i('Iniciando selección de imagen de perfil');  // Log de acción
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => imagenPerfil = File(picked.path));
        logger.i('Imagen de perfil seleccionada: ${picked.path}');  // Log de éxito
      } else {
        logger.w('Selección de imagen de perfil cancelada');  // Advertencia
      }
    } catch (e) {
      logger.e('Error al seleccionar imagen de perfil: $e');  // Log de error
    }
  }

  // ==============================================
  //               LÓGICA DE REGISTRO
  // ==============================================

  void registrar() async {
    logger.i('Iniciando proceso de registro');  // Log de inicio
    // 1. Marcar visualmente campos vacíos
    setState(() {
      errorName = name.text.isEmpty;
      errorCorreo = correo.text.isEmpty;
      errorContrasenya = contrasenya.text.isEmpty;
      errorConfirmar = confirmarContrasenya.text.isEmpty;
      errorPais = paisSeleccionado == null;
      errorAnio = anioSeleccionado == null;

      // Mensaje específico para correo
      if (correo.text.isEmpty) {
        errorCorreoMensaje = "Campo requerido";
        errorCorreo = true;
      } else if (!validarCorreo(correo.text)) {
        errorCorreoMensaje = "Formato inválido";
        errorCorreo = true;
      } else {
        errorCorreoMensaje = null;
        errorCorreo = false;
      }
    });

    // 2. Si hay errores visuales → mostrar mensaje y salir
    if (errorName ||
        errorCorreo ||
        errorContrasenya ||
        errorConfirmar ||
        errorPais ||
        errorAnio) {
          logger.w('Validación fallida: Campos requeridos incompletos');  // Advertencia
      mostrarMensaje("Por favor, completa todos los campos requeridos.");
      return;
    }

    // 3. Validaciones lógicas adicionales
    if (contrasenya.text != confirmarContrasenya.text) {
      setState(() {
        errorContrasenya = true;
        errorConfirmar = true;
      });
      logger.w('Validación fallida: Contraseñas no coinciden');
      mostrarMensaje("Las contraseñas no coinciden.");
      return;
    }

    if (!validarContrasenyaFuerte(contrasenya.text)) {
      setState(() {
        errorContrasenya = true;
        errorConfirmar = true;
      });
      logger.w('Validación fallida: Contraseña no cumple requisitos de fortaleza');  // Advertencia
      mostrarMensaje(
        "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.",
      );
      return;
    }

    // 4. Preparar imagen de perfil en base64 (si existe)
    String? base64Image;
    if (imagenPerfil != null) {
      final bytes = await imagenPerfil!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
      logger.d('Imagen de perfil preparada en base64');  // Debug
    }

    // 5. Llamada real al servicio de autenticación
    try {
      logger.i('Enviando datos de registro al servidor');
      final ok = await widget.authService.register(
        nombreUsuario: name.text,
        email: correo.text,
        contrasena: contrasenya.text,
        contrasena2: confirmarContrasenya.text,
        pais: paisSeleccionado,
        descripcion: descripcion.text,
        anioNacimiento: anioSeleccionado,
        fotoPerfil: base64Image,
      );

      // Éxito → mensaje y redirigir a login
      logger.i('Registro exitoso - Navegando a login');  // Log de éxito
      mostrarMensaje(
        "Usuario registrado exitosamente.",
        onClose: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(authService: widget.authService),
            ),
          );
        },
      );
    } catch (e) {
      // Error del backend (ej: usuario ya existe, email duplicado)
      logger.e('Error en registro: $e');  // Log de error
      mostrarMensaje(e.toString().replaceAll("Exception:", ""));
    }
  }

  // ==============================================
  //               HELPERS / DIÁLOGOS
  // ==============================================

  void mostrarMensaje(String mensaje, {VoidCallback? onClose}) {
    logger.d('Mostrando mensaje: $mensaje');  // Debug
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose();
            },
          ),
        ],
      ),
    );
  }

  // ==============================================
  //                   INTERFAZ
  // ==============================================

  @override
  Widget build(BuildContext context) {
    logger.i('Construyendo pantalla de registro');
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.appName,
                style: TextStyle(fontSize: 28, fontFamily: "Alegreya"),
              ),

              const SizedBox(height: 10),

              // Foto de perfil circular + selector
              Column(
                children: [
                  GestureDetector(
                    onTap: seleccionarImagen,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: imagenPerfil != null
                              ? FileImage(imagenPerfil!)
                              : null,
                        ),
                        if (imagenPerfil == null)
                          const Text(
                            "+",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.agregarFotoPerfil,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Campos de texto y dropdowns
              campoTexto(AppLocalizations.of(context)!.usuario, controller: name, error: errorName),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: dropdownPais()),
                  const SizedBox(width: 10),
                  Expanded(child: dropdownAnio()),
                ],
              ),

              const SizedBox(height: 10),

              campoTexto(
                AppLocalizations.of(context)!.correo,
                controller: correo,
                error: errorCorreo,
                errorTextMessage: errorCorreoMensaje,
              ),

              const SizedBox(height: 10),

              campoTexto(
                AppLocalizations.of(context)!.contrasenaRegistro,
                controller: contrasenya,
                esPassword: true,
                error: errorContrasenya,
              ),

              const SizedBox(height: 10),

              campoTexto(
                AppLocalizations.of(context)!.confirmarContrasena,
                controller: confirmarContrasenya,
                esPassword: true,
                error: errorConfirmar,
              ),

              const SizedBox(height: 10),

              campoTexto(
                AppLocalizations.of(context)!.descripcionOpcional,
                controller: descripcion,
                maxLineas: 5,
              ),

              const SizedBox(height: 25),

              // Botón principal de registro
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(250, 40),
                ),
                onPressed: registrar,
                child: Text(AppLocalizations.of(context)!.registrarse),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  //          COMPONENTES REUTILIZABLES
  // ==============================================

  Widget campoTexto(
    String label, {
    required TextEditingController controller,
    bool esPassword = false,
    int maxLineas = 1,
    bool error = false,
    String? errorTextMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: esPassword,
          maxLines: maxLineas,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            errorText: error ? (errorTextMessage ?? "Campo requerido") : null,
          ),
        ),
      ],
    );
  }

  Widget dropdownPais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("País"),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: paisSeleccionado,
          hint: const Text("Selecciona un país"),
          isExpanded: true,
          items: paises
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) {
            setState(() {
              paisSeleccionado = value;
              errorPais = false;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: errorPais ? "Campo requerido" : null,
          ),
        ),
      ],
    );
  }

  Widget dropdownAnio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.anioNacimiento),
        const SizedBox(height: 5),
        DropdownButtonFormField<int>(
          value: anioSeleccionado,
          hint: const Text("Selecciona un año"),
          isExpanded: true,
          items: anios
              .map((a) => DropdownMenuItem(value: a, child: Text("$a")))
              .toList(),
          onChanged: (value) {
            setState(() {
              anioSeleccionado = value;
              errorAnio = false;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: errorAnio ? "Campo requerido" : null,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    logger.i('Destruyendo pantalla de registro');  // Log de limpieza
    name.dispose();
    correo.dispose();
    contrasenya.dispose();
    confirmarContrasenya.dispose();
    descripcion.dispose();
    super.dispose();
  }
}
