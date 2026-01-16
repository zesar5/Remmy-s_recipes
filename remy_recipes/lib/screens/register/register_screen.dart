import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

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

  String? errorCorreoMensaje;

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

  void registrar() async{
    // Primero marcamos campos vacíos
    setState(() {
      errorName = name.text.isEmpty;
      errorCorreo = correo.text.isEmpty;
      errorContrasenya = contrasenya.text.isEmpty;
      errorConfirmar = confirmarContrasenya.text.isEmpty;
      errorPais = paisSeleccionado == null;
      errorAnio = anioSeleccionado == null;

      // Preparar mensaje para el correo: vacío o formato inválido
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

    // Si hay algún error visual, avisamos y no seguimos
    if (errorName ||
        errorCorreo ||
        errorContrasenya ||
        errorConfirmar ||
        errorPais ||
        errorAnio) {
      mostrarMensaje("Por favor, completa todos los campos requeridos.");
      return;
    }

    // Validaciones lógicas adicionales (contraseñas)
    if (contrasenya.text != confirmarContrasenya.text) {
      setState(() {
        errorContrasenya = true;
        errorConfirmar = true;
      });
      mostrarMensaje("Las contraseñas no coinciden.");
      return;
    }

    if (!validarContrasenyaFuerte(contrasenya.text)) {
      setState(() {
        errorContrasenya = true;
        errorConfirmar = true;
      });
      mostrarMensaje(
          "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.");
      return;
    }

    // Si todo OK
    String? base64Image;
    if (imagenPerfil != null) {
      final bytes = await imagenPerfil!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
    }

    try {
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

      mostrarMensaje("Usuario registrado exitosamente.", onClose: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(authService: widget.authService),
          ),
        );
      });
    } catch (e) {
      mostrarMensaje(e.toString().replaceAll("Exception:", ""));
    }
  }
  

  void mostrarMensaje(String mensaje, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              if (onClose != null) {
                onClose(); // Ejecuta la acción extra
              }
            },
          )
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
                  style: TextStyle(fontSize: 28, fontFamily: "Alegreya")),

              SizedBox(height: 10),

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
    SizedBox(height: 8),
    Text(
      "Añadir foto de perfil",
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      
    ),
    
  ],
  
  
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
                  controller: correo,
                  error: errorCorreo,
                  errorTextMessage: errorCorreoMensaje),

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
                  controller: descripcion,
                  maxLineas: 5,
                  ),

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
    bool error = false,
    String? errorTextMessage}) {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          // bordes de error para que se vea claramente en rojo
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(10),
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
      Text("País"),
      SizedBox(height: 5),
      DropdownButtonFormField<String>(
        value: paisSeleccionado,
        hint: Text("Selecciona un país"), // <-- evita que el dropdown quede 'deshabilitado' cuando value == null
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
      Text("Año nacimiento"),
      SizedBox(height: 5),
      DropdownButtonFormField<int>(
        value: anioSeleccionado,
        hint: Text("Selecciona un año"),
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
}