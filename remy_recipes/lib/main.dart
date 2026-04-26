import 'package:flutter/material.dart';
import 'package:remy_recipes/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:logger/logger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/config/env_config.dart';
import 'widgets/session_expired_dialog.dart';

final AuthService authService = AuthService();

// Clave global para acceder al contexto de la app desde cualquier lugar
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Environment.initialize();

  logger.i('Iniciando app - Verificando auto-login');
  final bool isLoggedIn = await authService.tryAutoLogin();
  logger.d('Auto-login completado: isLoggedIn = $isLoggedIn');
  
  runApp(RemmyApp(isLoggedIn: isLoggedIn));
}

/// Muestra diálogo de sesión caducada y redirige a login
void _mostrarSesionCaducada() {
  final context = navigatorKey.currentContext;
  if (context == null) {
    logger.e('❌ No hay contexto disponible para mostrar diálogo');
    return;
  }

  logger.w('🔴 Mostrando diálogo de sesión caducada');
  
  // Mostrar diálogo
  SessionExpiredDialog.show(
    context,
    onLoginTapped: () {
      logger.i('Usuario presionó: Ir al login');
      // Redirigir a login y limpiar el stack de navegación
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    },
  );
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

class RemmyApp extends StatefulWidget {
  final bool isLoggedIn;

  const RemmyApp({super.key, required this.isLoggedIn});

  // 👇 MÉTODO GLOBAL PARA CAMBIAR IDIOMA
  static void setLocale(BuildContext context, Locale newLocale) {
    final _RemmyAppState? state = context
        .findAncestorStateOfType<_RemmyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<RemmyApp> createState() => _RemmyAppState();
}

class _RemmyAppState extends State<RemmyApp> {
  Locale? _locale; // idioma por defecto

  @override
  void initState() {
    super.initState();
    // Registrar callback DESPUÉS de que el widget esté construido
    // para que el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.i('🔐 Registrando callback de sesión expirada');
      authService.registerSessionExpiredCallback(() {
        _mostrarSesionCaducada();
      });
    });
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.i(
      'Construyendo RemmyApp - Ruta inicial: ${widget.isLoggedIn ? "/home" : "/login"}',
    );

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      
      navigatorKey: navigatorKey, // 👈 Agregado para acceder al Navigator globalmente

      locale: _locale,

      supportedLocales: const [Locale('es'), Locale('en')],

      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Si el usuario ya cambió idioma manualmente
        if (_locale != null) {
          return _locale;
        }

        // Si el idioma del dispositivo está soportado
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return locale;
          }
        }

        // Si no coincide ninguno → español por defecto
        return const Locale('es');
      },

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: widget.isLoggedIn ? '/home' : '/login',

      routes: {
        "/login": (_) => LoginScreen(authService: authService),
        "/register": (_) => RegisterScreen(authService: authService),
        "/home": (_) => HomeScreen(authService: authService),
      },
    );
  }
}
