import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService (simulado)', () {
    test('Login devuelve true con credenciales válidas', () async {
      Future<bool> fakeLogin(String email, String pass) async {
        return email == 'test@gmail.com' && pass == '1234';
      }

      final result = await fakeLogin('test@gmail.com', '1234');

      expect(result, true);
    });

    test('Login falla con credenciales incorrectas', () async {
      Future<bool> fakeLogin(String email, String pass) async {
        return false;
      }

      final result = await fakeLogin('x@gmail.com', '0000');

      expect(result, false);
    });
  });
}