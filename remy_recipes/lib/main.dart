import 'package:flutter/material.dart';
import 'package:remy_recipes/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:logger/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

final AuthService authService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  logger.i('Iniciando app - Verificando auto-login');
  final bool isLoggedIn = await authService.tryAutoLogin();
  logger.d('Auto-login completado: isLoggedIn = $isLoggedIn');
  runApp( RemmyApp(isLoggedIn: isLoggedIn ));
}

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

class RemmyApp extends StatelessWidget {
  final bool isLoggedIn;
   RemmyApp({super.key, required this.isLoggedIn});


  @override
  Widget build(BuildContext context) {
    logger.i('Construyendo RemmysApp - Ruta inicial:  ${isLoggedIn ? "/home" : "/login"}');
    return MaterialApp(
      // TÍTULO USANDO LOCALIZACIÓN
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,

      debugShowCheckedModeBanner: false,
      
      // IDIOMA BASE (ESPAÑOL)
      locale: const Locale('en'),

      // IDIOMAS SOPORTADOS
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],

      // DELEGATES DE LOCALIZACIÓN
      localizationsDelegates: const [
        AppLocalizations.delegate, // 👈 TU APP
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      //Quitar la etiqueta DEBUG
      initialRoute: isLoggedIn ? '/home': '/login',

      routes: {
        "/login": (_) => LoginScreen(authService: authService),
        "/register": (_) => RegisterScreen(authService: authService),
        "/home": (_) =>HomeScreen(authService: authService),
      },
    );
  }
}

