import 'package:remy_recipes/main.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'terms_screen.dart';
import '../l10n/app_localizations.dart';
import 'forgot_password_email_screen.dart';

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
    logger.i('Iniciando login para email: $correo'); // Log de inicio

    // Reiniciar errores visuales
    setState(() {
      _errorCorreo = false;
      _errorContrasena = false;
    });

    // Validaciones locales (como en WPF)
    if (correo.isEmpty) {
      logger.w('Validación fallida: Correo vacío');
      setState(() => _errorCorreo = true);
      _showErrorDialog(
        AppLocalizations.of(context)!.campoVacio,
        AppLocalizations.of(context)!.correoVacioMsg,
      );
      return;
    }
    if (!_esCorreoValido(correo)) {
      logger.w('Validación fallida: Correo inválido'); // Advertencia
      setState(() => _errorCorreo = true);
      _showErrorDialog(
        AppLocalizations.of(context)!.correoInvalido,
        AppLocalizations.of(context)!.correoInvalidoMsg,
      );
      return;
    }
    if (contrasena.isEmpty) {
      logger.w('Validación fallida: Contraseña vacía');
      setState(() => _errorContrasena = true);
      _showErrorDialog(
        AppLocalizations.of(context)!.campoVacio,
        AppLocalizations.of(context)!.correoVacioMsg,
      );
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
        logger.i(
          'Login exitoso. Token en AuthService: ${widget.authService.accessToken}',
        ); //puede que el widget.authService.accesToken no vaya ahí(revisar)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(authService: widget.authService),
          ),
        );
      } else {
        logger.e('Login fallido: Credenciales incorrectas');
        _showErrorDialog(
          AppLocalizations.of(context)!.errorInicioSesion,
          AppLocalizations.of(context)!.credencialesIncorrectas,
        );
      }
    } catch (e) {
      if (!mounted) return;
      logger.e('Error en login: $e');
      _showErrorDialog(
        AppLocalizations.of(context)!.errorConexion,
        e.toString().replaceFirst('Exception: ', ''),
      );
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
    logger.d('Mostrando diálogo de error: $title'); // Debug
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // ==== BUILD UI ====
  @override
  Widget build(BuildContext context) {
    logger.i('Construyendo pantalla de login');
    return Scaffold(
      backgroundColor: const Color(0xFFDEB887), // BurlyWood
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),

            Text(
              AppLocalizations.of(context)!.appName,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.correoElectronico,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            //Borde rojo
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: _errorCorreo
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.contrasena,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            // ← Y AQUÍ PARA LA CONTRASEÑA
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: _errorContrasena
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: TextField(
                controller: _contrasenaController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarContrasena
                          ? Icons.visibility_off
                          : Icons.visibility,
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ForgotPasswordEmailScreen(
                      authService: widget.authService,
                    ),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.olvidarContrasena,
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 10),
            _buildActionButton(
              text: AppLocalizations.of(context)!.iniciarSesion,
              color: Colors.black,
              textColor: Colors.white,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 20),
            _buildActionButton(
              text: AppLocalizations.of(context)!.registrarse,
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () {
                logger.i(
                  'Navegando a pantalla de registro',
                ); // Log de navegación
                Navigator.of(context).pushNamed('/register');
              },
            ),

            const SizedBox(height: 25),
            TextButton(
              onPressed: () {
                logger.i(
                  'Omitiendo login - Navegando a Home',
                ); // Log de navegación
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      authService: widget
                          .authService, // puedes pasar el mismo AuthService
                    ),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.omitir,
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 30),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Al continuar aceptas los ',
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                  child: const Text(
                    'Terminos de Servicio',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text('y la', style: TextStyle(color: Colors.black)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    );
                  },
                  child: const Text(
                    'Politica de privacidad',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
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
