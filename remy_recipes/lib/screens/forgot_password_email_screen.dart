import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/validators.dart'; // Para validarCorreo
import 'forgot_password_code_screen.dart';
import '../main.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  final AuthService authService;
  const ForgotPasswordEmailScreen({super.key, required this.authService});

  @override
  State<ForgotPasswordEmailScreen> createState() => _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _errorEmail = false;
  String? _errorEmailMessage;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    setState(() {
      _errorEmail = false;
      _errorEmailMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        _errorEmail = true;
        _errorEmailMessage = "Campo requerido";
      });
      mostrarMensaje("Por favor, introduce tu correo.");
      return;
    }
    if (!validarCorreo(email)) {
      setState(() {
        _errorEmail = true;
        _errorEmailMessage = "Formato inválido";
      });
      mostrarMensaje("Correo inválido.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authService.sendResetCode(email);
      logger.i('Código enviado a $email');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordCodeScreen(authService: widget.authService, email: email),
        ),
      );
    } catch (e) {
      logger.e('Error enviando código: $e');
      mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Recuperar Contraseña',
                style: TextStyle(fontSize: 28, fontFamily: "Alegreya"),
              ),
              const SizedBox(height: 20),
              campoTexto(
                "Correo electrónico",
                controller: _emailController,
                error: _errorEmail,
                errorTextMessage: _errorEmailMessage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(250, 40),
                ),
                onPressed: _isLoading ? null : _sendCode,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar Código'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto(
    String label, {
    required TextEditingController controller,
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
}