import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart'as http;
import '../screens/recipes/recipes_form_page.dart';
const String _baseUrl = 'http://10.0.2.2:8000';

// ==========================================================================
// RECETAAAAAAAAAAAS
// ==========================================================================

class Receta{
  final String titulo;
  final String ingredientes;
  final String pasos;
  final Int duracion;
  final String pais;
  final String alergenos;
  final String estacion;
 
 
  Receta ({
    required this.titulo,
    required this.ingredientes,
    required this.pasos,
    required this.duracion,
    required this.pais,
    required this.alergenos,
    required this.estacion,
   

});
// constructor para crear un objeto Receta
factory Receta.fromJson(Map<String,dynamic> json){
  return Receta(
    titulo: json['titulo'] as String,
   ingredientes: json['ingredientes'] as String,
    pasos: json['pasos'] as String,
     duracion: json['duracion'] as Int,
      pais: json['pais'] as String,
       alergenos: json['alergenos'] as String,
        estacion: json['estacion'] as String,
        );
}
}