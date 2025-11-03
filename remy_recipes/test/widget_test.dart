
import 'package:flutter_test/flutter_test.dart';

import 'package:remy_recipes/main.dart'; // Asegurate de que este import apunte al nombre correcto de tu proyecto

void main() {
  testWidgets('Verifica si la aplicacion tiene el texto "Remmy\'s Recipes"', (WidgetTester tester) async {
    // Construye nuestra aplicacion y dispara un frame.
    // === CORRECCION: Cambiamos 'MyApp' por 'RemyRecipesApp' ===
    await tester.pumpWidget(const RemyRecipesApp()); 
    // =========================================================

    // Busca el texto "Remmy's Recipes" en la pantalla de Login
    expect(find.text('Remmy\'s Recipes'), findsOneWidget);
    
    // Verifica que los botones de Login y Registro existan
    expect(find.text('Iniciar Sesion'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
  });
}
