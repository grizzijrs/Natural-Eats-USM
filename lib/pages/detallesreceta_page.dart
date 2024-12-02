import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyectodam/services/fs_service.dart';
import 'package:proyectodam/constants.dart';

class DetallesrecetaPage extends StatelessWidget {
  final Map<String, dynamic> receta;
  final String recetaId;
  final FsService fsService = FsService();
  final User user;

  DetallesrecetaPage(
      {required this.receta, required this.recetaId, required this.user});

  @override
  Widget build(BuildContext context) {
    String imagenPath = receta['imagen'] ?? '';

    return Scaffold(
      backgroundColor: Color(kColorPrincipal),
      appBar: AppBar(
        backgroundColor: Color(kColorAppBar),
        title: Text(
          receta['nombre'] ?? "Detalles de la receta",
          style: TextStyle(color: Color(kColorTexto)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                receta['nombre'] ?? 'Sin nombre',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(kColorTexto),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            if (imagenPath.isNotEmpty)
              Image.asset(
                'assets/images/$imagenPath',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Datos",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(kColorTexto),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    "Autor: ${receta['autor'] ?? 'Desconocido'}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(kColorTexto),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Categoría: ${receta['categoria'] ?? 'Sin categoría'}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(kColorTexto),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Instrucciones",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(kColorTexto),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Text(
              receta['instrucciones'] ?? "Sin instrucciones",
              style: TextStyle(
                fontSize: 18,
                color: Color(kColorTexto),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar esta receta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await fsService.borrarReceta(recetaId);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Receta eliminada con éxito")));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
