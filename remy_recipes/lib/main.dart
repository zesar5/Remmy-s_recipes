import 'package:flutter/material.dart';
import 'package:remy_recipes/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';


final AuthService authService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await authService.tryAutoLogin();
  runApp( RemmyApp(isLoggedIn: isLoggedIn ));
}

class RemmyApp extends StatelessWidget {
  final bool isLoggedIn;
   RemmyApp({super.key, required this.isLoggedIn});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Remmy's Recipes",
      debugShowCheckedModeBanner: false, //Quitar la etiqueta DEBUG
      initialRoute: isLoggedIn ? '/home': '/login',
      routes: {
        "/login": (_) => LoginScreen(authService: authService),
        "/register": (_) => RegisterScreen(authService: authService),
        "/home": (_) =>HomeScreen(authService: authService),
      },
    );
  }
}

