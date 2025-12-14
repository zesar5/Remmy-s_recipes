import '../../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import '../home/home_screen.dart';
const String _baseUrl = 'http://10.0.2.2:8000';
//const String _baseUrl = 'http://localhost:8000';
// ==========================================================================
// 4. PANTALLA DE INICIO DE SESION 
// ==========================================================================
class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _isLoading = false;

  // NUEVOS FLAGS PARA BORDES ROJOS
  bool _errorCorreo = false;
  bool _errorContrasena = false;
  
  // ==== LOGIN HANDLER ====
  Future<void> _handleLogin() async {
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    // Reiniciar errores visuales
    setState(() {
      _errorCorreo = false;
      _errorContrasena = false;
    });

    // Validaciones locales (como en WPF)
    if (correo.isEmpty) {
      setState(() => _errorCorreo = true);
      _showErrorDialog('Campo vacío', 'Por favor, introduce tu correo electrónico.');
      return;
    }
    if (!_esCorreoValido(correo)) {
      setState(() => _errorCorreo = true);
      _showErrorDialog('Correo inválido', 'El formato del correo no es válido.');
      return;
    }
    if (contrasena.isEmpty) {
      setState(() => _errorContrasena = true);
      _showErrorDialog('Campo vacío', 'Por favor, introduce tu contraseña.');
      return;
    }

    // Simulación del backend real
    setState(() => _isLoading = true);
    try {
      final success = await widget.authService.login(
        email: correo,
        password: contrasena,
      );

      if (!mounted) return;

      if (success) {
        print('Login exitoso. Token en AuthService: ${widget.authService.accessToken}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              authService: widget.authService,
            ),
          ),
        );
      } else {
        _showErrorDialog('Error de inicio de sesión', 'Credenciales incorrectas.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error de conexión', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==== UTILIDADES ====
  bool _esCorreoValido(String correo) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(correo);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // ==== BUILD UI ====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887), // BurlyWood
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),

            const Text(
              "Remmy's Recipes",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Alegreya',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
           Transform.scale(
           scale: 1.7, // Ajusta el tamaño sin cambiar el espacio que ocupa
           child: Image.asset(
            'assets/logosinfondoBien.png',
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.2,
            fit: BoxFit.contain,
            ),
          ),
            const SizedBox(height: 40),

            // CORREO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Correo electrónico",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            //Borde rojo
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: _errorCorreo ? Border.all(color: Colors.red, width: 2) : null,
              ),
              child: TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Contraseña",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            // ← Y AQUÍ PARA LA CONTRASEÑA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: _errorContrasena ? Border.all(color: Colors.red, width: 2) : null,
              ),
              child: TextField(
                controller: _contrasenaController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarContrasena = !_ocultarContrasena;
                      });
                    },
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () => _showErrorDialog(
                'Recuperar contraseña',
                'Te enviaremos un enlace para restablecer tu contraseña.',
              ),
              child: const Text(
                'He olvidado la contraseña',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 10),
            _buildActionButton(
              text: 'Iniciar Sesión',
              color: Colors.black,
              textColor: Colors.white,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 20),
            _buildActionButton(
              text: 'Registrarse',
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
            ),

            const SizedBox(height: 25),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text(
                'Omitir',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Al hacer click, aceptas nuestros Términos de",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue),
            ),
            const Text(
              "servicio y Política de privacidad",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==== BOTÓN ESTILIZADO ====
  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}