import 'package:flutter_test/flutter_test.dart';
import 'package:remy_recipes/data/models/receta.dart';

void main() {
  group('Modelo Receta', () {

    test('fromJson crea una receta correctamente', () {
      final json = {
        'Id_receta': 1,
        'titulo': 'Pizza',
        'duracion': 30,
      };

      final receta = Receta.fromJson(json);

      expect(receta.id, '1');
      expect(receta.titulo, 'Pizza');
      expect(receta.duracion, 30);
    });

    test('fromHomeJson crea una receta ligera correctamente', () {
      final json = {
        'Id_receta': 15,
        'titulo': 'Hamburguesa',
        'imagen': null,
      };

      final receta = Receta.fromHomeJson(json);

      expect(receta.id, '15');
      expect(receta.titulo, 'Hamburguesa');
      expect(receta.imagenBase64, null);
    });

    test('fromJson maneja campos opcionales null', () {
      final json = {
        'Id_receta': 3,
        'titulo': 'Sopa',
        'duracion': null,
      };

      final receta = Receta.fromJson(json);

      expect(receta.id, '3');
      expect(receta.titulo, 'Sopa');
    });

    test('toJson devuelve un mapa válido', () {
      final receta = Receta(
        id: '1',
        titulo: 'Pasta',
        duracion: 20,
      );

      final json = receta.toJson();

      expect(json['titulo'], 'Pasta');
      expect(json['duracion'], 20);
    });
  });
}
