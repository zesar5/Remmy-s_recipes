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

  List<int> anios = [
    for (int i = DateTime.now().year; i >= 1900; i--) i
  ];

  // ===== VALIDACIONES =====

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

  // ===== FOTO DE PERFIL =====

  Future<void> seleccionarImagen() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imagenPerfil = File(picked.path);
      });
    }
  }

  // ===== REGISTRO =====

  void registrar() {
    if (name.text.isEmpty ||
        correo.text.isEmpty ||
        contrasenya.text.isEmpty ||
        confirmarContrasenya.text.isEmpty ||
        paisSeleccionado == null ||
        anioSeleccionado == null) {
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

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Remmy's Recipes",
                style: TextStyle(
                    fontSize: 28, fontFamily: "Times New Roman"),
              ),

              SizedBox(height: 10),

              // ===== CÍRCULO IMAGEN =====
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
                      Text(
                        "+",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      )
                  ],
                ),
              ),

              SizedBox(height: 25),

              // ===== USUARIO =====
              campoTexto("Usuario", controller: name),

              SizedBox(height: 10),

              // ===== PAÍS Y AÑO =====
              Row(
                children: [
                  Expanded(child: dropdownPais()),
                  SizedBox(width: 10),
                  Expanded(child: dropdownAnio()),
                ],
              ),

              SizedBox(height: 10),

              campoTexto("Correo electrónico", controller: correo),
              SizedBox(height: 10),
              campoTexto("Contraseña",
                  controller: contrasenya, esPassword: true),
              SizedBox(height: 10),
              campoTexto("Confirmar contraseña",
                  controller: confirmarContrasenya, esPassword: true),
              SizedBox(height: 10),
              campoTexto("Descripción (opcional)",
                  controller: descripcion, maxLineas: 3),

              SizedBox(height: 25),

              // ===== BOTÓN REGISTRO =====
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(250, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: registrar,
                child: Text("Registrarse"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // COMPONENTES REUTILIZABLES

  Widget campoTexto(String label,
      {required TextEditingController controller,
      bool esPassword = false,
      int maxLineas = 1}) {
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          onChanged: (v) => setState(() => paisSeleccionado = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          onChanged: (v) => setState(() => anioSeleccionado = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}