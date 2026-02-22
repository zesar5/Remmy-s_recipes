import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/validators.dart'; // Para validarContrasenyaFuerte
import '../main.dart';

class ForgotPasswordNewPasswordScreen extends StatefulWidget {
  final AuthService authService;
  final String resetToken;
  const ForgotPasswordNewPasswordScreen({
    super.key,
    required this.authService,
    required this.resetToken,
  });

  @override
  State<ForgotPasswordNewPasswordScreen> createState() =>
      _ForgotPasswordNewPasswordScreenState();
}

class _ForgotPasswordNewPasswordScreenState
    extends State<ForgotPasswordNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _errorPassword = false;
  String? _errorPasswordMessage;

  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    setState(() {
      _errorPassword = false;
      _errorPasswordMessage = null;
    });

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorPassword = true;
        _errorPasswordMessage = AppLocalizations.of(context)!.camposRequeridos;
      });
      mostrarMensaje(AppLocalizations.of(context)!.completaTodosLosCampos);
      return;
    }
    if (newPass != confirmPass) {
      setState(() {
        _errorPassword = true;
        _errorPasswordMessage = AppLocalizations.of(context)!.noCoinciden;
      });
      mostrarMensaje(AppLocalizations.of(context)!.contrasenyaNoCoinciden);
      return;
    }
    if (!validarContrasenyaFuerte(newPass)) {
      setState(() {
        _errorPassword = true;
        _errorPasswordMessage = AppLocalizations.of(context)!.debil;
      });
      mostrarMensaje(
        AppLocalizations.of(context)!.requisitosContrasenya,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authService.resetPassword(widget.resetToken, newPass);
      logger.i('Contraseña cambiada');
      mostrarMensaje(
        AppLocalizations.of(context)!.contrasenyaCambiada,
        onClose: () {
          Navigator.of(
            context,
          ).popUntil((route) => route.isFirst); // Vuelve a LoginScreen
        },
      );
    } catch (e) {
      logger.e('Error cambiando contraseña: $e');
      mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void mostrarMensaje(String mensaje, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.informacion),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose();
            },
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
                AppLocalizations.of(context)!.nuevaContrasenya,
                style: TextStyle(fontSize: 28, fontFamily: "Alegreya"),
              ),
              const SizedBox(height: 20),
              campoTexto(
                AppLocalizations.of(context)!.nuevaContrasenya,
                controller: _newPasswordController,
                esPassword: true,
                error: _errorPassword,
                errorTextMessage: _errorPasswordMessage,
              ),
              const SizedBox(height: 10),
              campoTexto(
                AppLocalizations.of(context)!.confirmarContrasena,
                controller: _confirmPasswordController,
                esPassword: true,
                error: _errorPassword,
                errorTextMessage: _errorPasswordMessage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(250, 40),
                ),
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)!.cambiarContrasenya),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.volver,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  //          COMPONENTE REUTILIZABLE (COPIADO DE RegisterScreen)
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
            errorText: error ? (errorTextMessage ?? AppLocalizations.of(context)!.campoRequerido) : null,
          ),
        ),
      ],
    );
  }
}
