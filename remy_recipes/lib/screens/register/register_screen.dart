import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

const String _baseUrl = 'http://127.0.0.1:8000';

// ==========================================================================
// 5. PANTALLA DE REGISTRO
// ==========================================================================
class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final correo = TextEditingController();
  final contrasenya = TextEditingController();
  final confirmarContrasenya = TextEditingController();
  final descripcion = TextEditingController();

  String? paisSeleccionado;
  int? anioSeleccionado;

  File? imagenPerfil;

  final picker = ImagePicker();

  // ====== FLAGS DE ERROR ======
  bool errorName = false;
  bool errorCorreo = false;
  bool errorContrasenya = false;
  bool errorConfirmar = false;
  bool errorPais = false;
  bool errorAnio = false;

  List<String> paises = [ /* ... tus países ... */ ];
  List<int> anios = [ for (int i = DateTime.now().year; i >= 1900; i--) i ];

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

  Future<void> seleccionarImagen() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imagenPerfil = File(picked.path));
    }
  }

  // ===================== REGISTRO =====================

  void registrar() {
    setState(() {
      errorName = name.text.isEmpty;
      errorCorreo = correo.text.isEmpty;
      errorContrasenya = contrasenya.text.isEmpty;
      errorConfirmar = confirmarContrasenya.text.isEmpty;
      errorPais = paisSeleccionado == null;
      errorAnio = anioSeleccionado == null;
    });

    if (errorName ||
        errorCorreo ||
        errorContrasenya ||
        errorConfirmar ||
        errorPais ||
        errorAnio) {
      mostrarMensaje("Por favor, completa todos los campos requeridos.");
      return;
    }

    if (!validarCorreo(correo.text)) {
      mostrarMensaje("El correo electrónico no tiene un formato válido.");
      return;
    }

    if (contrasenya.text != confirmarContrasenya.text) {
      mostrarMensaje("Las contraseñas no coinciden.");
      return;
    }

    if (!validarContrasenyaFuerte(contrasenya.text)) {
      mostrarMensaje(
          "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.");
      return;
    }

    mostrarMensaje("Registro completado correctamente.");
  }

  void mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(child: Text("OK"), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text("Remmy's Recipes",
                  style: TextStyle(fontSize: 28, fontFamily: "Times New Roman")),

              SizedBox(height: 10),

              GestureDetector(
                onTap: seleccionarImagen,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          imagenPerfil != null ? FileImage(imagenPerfil!) : null,
                    ),
                    if (imagenPerfil == null)
                      Text("+",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey))
                  ],
                ),
              ),

              SizedBox(height: 25),

              campoTexto("Usuario",
                  controller: name, error: errorName),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: dropdownPais()),
                  SizedBox(width: 10),
                  Expanded(child: dropdownAnio()),
                ],
              ),

              SizedBox(height: 10),

              campoTexto("Correo electrónico",
                  controller: correo, error: errorCorreo),

              SizedBox(height: 10),

              campoTexto("Contraseña",
                  controller: contrasenya,
                  esPassword: true,
                  error: errorContrasenya),

              SizedBox(height: 10),

              campoTexto("Confirmar contraseña",
                  controller: confirmarContrasenya,
                  esPassword: true,
                  error: errorConfirmar),

              SizedBox(height: 10),

              campoTexto("Descripción (opcional)",
                  controller: descripcion),

              SizedBox(height: 25),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(250, 40),
                ),
                onPressed: registrar,
                child: Text("Registrarse"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTES =================

  Widget campoTexto(String label,
      {required TextEditingController controller,
      bool esPassword = false,
      int maxLineas = 1,
      bool error = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: esPassword,
          maxLines: maxLineas,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            errorText: error ? "Campo requerido" : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget dropdownPais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("País"),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: paisSeleccionado,
          items: paises
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() {
            paisSeleccionado = v;
            errorPais = false;
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            errorText: errorPais ? "Campo requerido" : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget dropdownAnio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Año nacimiento"),
        SizedBox(height: 5),
        DropdownButtonFormField<int>(
          value: anioSeleccionado,
          items: anios
              .map((a) => DropdownMenuItem(value: a, child: Text("$a")))
              .toList(),
          onChanged: (v) => setState(() {
            anioSeleccionado = v;
            errorAnio = false;
          }),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            errorText: errorAnio ? "Campo requerido" : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}