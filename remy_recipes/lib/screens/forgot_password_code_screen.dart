import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'forgot_password_new_password_screen.dart';
import 'package:logger/logger.dart';
import '../main.dart';

class ForgotPasswordCodeScreen extends StatefulWidget {
  final AuthService authService;
  final String email;
  const ForgotPasswordCodeScreen({super.key, required this.authService, required this.email});

  @override
  State<ForgotPasswordCodeScreen> createState() => _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState extends State<ForgotPasswordCodeScreen> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _errorCode = false;

  @override
  void dispose() {
    _codeControllers.forEach((c) => c.dispose());
    _codeFocusNodes.forEach((f) => f.dispose());
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    setState(() => _errorCode = false);

    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _errorCode = true);
      mostrarMensaje("Introduce un código de 6 dígitos válido.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resetToken = await widget.authService.verifyResetCode(code);
      logger.i('Código verificado para ${widget.email}');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordNewPasswordScreen(authService: widget.authService, resetToken: resetToken),
        ),
      );
    } catch (e) {
      logger.e('Error verificando código: $e'); 
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
                'Introduce el Código',
                style: TextStyle(fontSize: 28, fontFamily: "Alegreya"),
              ),
              const SizedBox(height: 20),
              Text('Hemos enviado un código a ${widget.email}. Introduce los 6 dígitos:'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _codeFocusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        errorBorder: _errorCode ? OutlineInputBorder(borderSide: BorderSide(color: Colors.red)) : null,
                        counterText: '',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _codeFocusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(250, 40),
                ),
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verificar Código'),
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
}