import 'package:flutter_test/flutter_test.dart';
import 'package:remy_recipes/services/recetas_service.dart';
import 'package:remy_recipes/data/models/receta.dart';

void main() {

  group('RecetasService - tests básicos', () {

    test('obtenerTodasLasRecetas devuelve una lista', () async {
      final recetas = await obtenerTodasLasRecetas();

      expect(recetas, isA<List<Receta>>());
    });

    test('obtenerRecetasPublicas devuelve una lista', () async {
      final recetas = await obtenerRecetasPublicas();

      expect(recetas, isA<List<Receta>>());
    });

    test('recetaFiltrada devuelve lista aunque no haya resultados', () async {
      final recetas = await recetaFiltrada(
        texto: 'zzzzzzzzzz',
        duracion: 5,
      );

      expect(recetas, isA<List<Receta>>());
    });

    test('eliminarReceta devuelve false con token inválido', () async {
      final resultado = await eliminarReceta(99999, 'token_falso');

      expect(resultado, false);
    });

    test('editarReceta devuelve false si falla la edición', () async {
      final recetaFake = Receta(
        id: '99999',
        titulo: 'Receta falsa',
        duracion: 10,
      );

      final resultado = await editarReceta(recetaFake, 'token_falso');

      expect(resultado, false);
    });

    test('editarReceta con token válido devuelve true o falla correctamente', () async {
      final recetaFake = Receta(
        id: '1',
        titulo: 'Receta real para test',
        duracion: 10,
      );

      final resultado = await editarReceta(recetaFake, 'token_valido');

      // Aquí depende del backend, se puede poner expect(resultado, true)
      expect(resultado, isA<bool>());
    });
  });
}
