import 'dart:math';

import '../../services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:remy_recipes/data/models/usuario.dart';

class ComunidadScreen extends StatefulWidget {
  @override
  _ComunidadScreenState createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  List<Usuario> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    final response = await http.get(Uri.parse(ApiEndpoints.comunidad));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        usuarios = data.map((e) => Usuario.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar usuarios");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Remmy´s Recipes'), leading: BackButton()),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final user = usuarios[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.userName[0])),
                  title: Text(user.userName),
                  onTap: () {
                    Navigator.pushNamed(context, '/perfil', arguments: user.id);
                  },
                );
              },
            ),
    );
  }
}
