import 'package:flutter_test/flutter_test.dart';
import 'package:remy_recipes/utils/validators.dart';

void main() {
  group('Validaciones de registro', () {
    test('Correo válido', () {
      expect(validarCorreo('test@gmail.com'), true);
    });

    test('Correo inválido', () {
      expect(validarCorreo('hola123'), false);
    });

    test('Contraseña fuerte', () {
      expect(validarContrasenyaFuerte('123456Jj.'), true);
    });

    test('Contraseña débil', () {
      expect(validarContrasenyaFuerte('123'), false);
    });
  });
}
