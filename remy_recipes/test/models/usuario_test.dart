import 'package:flutter_test/flutter_test.dart';
import 'package:remy_recipes/data/models/usuario.dart';

void main() {
  group('Modelo Usuario', () {
    test('fromJson crea usuario correctamente', () {
      final json = {
        'Id_usuario': 5,
        'nombre': 'Juan',
        'email': 'juan@gmail.com',
      };

      final usuario = Usuario.fromJson(json);

      expect(usuario.id, '5'); // string
      expect(usuario.userName, 'Juan');
      expect(usuario.email, 'juan@gmail.com');
    });

    test('toJsonRegistro devuelve datos correctos', () {
      final usuario = Usuario(
        id: '6',
        userName: 'Ana',
        email: 'ana@gmail.com',
        contrasena: '123456',
        contrasena2: '123456',
      );

      final json = usuario.toJsonRegistro();

      expect(json['nombre'], 'Ana');
      expect(json['email'], 'ana@gmail.com');
      expect(json.containsKey('contrasena'), true);
    });
  });
}
