import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login/login_screen.dart';
import 'screens/recipes/recipes_form_page.dart';
import 'screens/register/register_screen.dart';

import 'screens/home/home_screen.dart';


final AuthService authService = AuthService();

void main() {
  runApp(const RemmyApp());
}

class RemmyApp extends StatelessWidget {
  const RemmyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Remmy's Recipes",
      initialRoute: "/login",
      routes: {
        "/login": (_) => LoginScreen(authService: authService),
        "/register": (_) => RegisterScreen(authService: authService),
        
      },
    );
  }
}