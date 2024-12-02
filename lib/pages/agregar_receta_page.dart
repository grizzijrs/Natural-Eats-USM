import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectodam/constants.dart';

class AgregarRecetaPage extends StatefulWidget {
  final String autor;
  final Function agregarRecetaCallback;

  AgregarRecetaPage({required this.autor, required this.agregarRecetaCallback});

  @override
  _AgregarRecetaPageState createState() => _AgregarRecetaPageState();
}

class _AgregarRecetaPageState extends State<AgregarRecetaPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  String? _categoriaSeleccionada;
  String? _imagenSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Receta"),
        backgroundColor: Color(kColorAppBar),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(kInicioFondoDegradado),
              Color(kFinFondoDegradado),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "NaturalEats",
              style: TextStyle(
                fontSize: 24,
                color: Color(kColorTexto),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nombre de la receta",
                labelStyle: TextStyle(color: Color(kColorTexto)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(kColorSecundario)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(kColorPrincipal)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: instructionsController,
              decoration: InputDecoration(
                labelText: "Instrucciones",
                labelStyle: TextStyle(color: Color(kColorTexto)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(kColorSecundario)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(kColorPrincipal)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categoria')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  List<DropdownMenuItem<String>> items =
                      snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc['nombre'],
                      child: Text(doc['nombre']),
                      onTap: () {
                        setState(() {
                          _imagenSeleccionada = doc['imagen'];
                        });
                      },
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Categoría",
                      labelStyle: TextStyle(color: Color(kColorTexto)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(kColorSecundario)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(kColorPrincipal)),
                      ),
                    ),
                    value: _categoriaSeleccionada,
                    items: items,
                    onChanged: (value) {
                      setState(() {
                        _categoriaSeleccionada = value!;
                      });
                    },
                  );
                }

                return const Text('No hay datos disponibles');
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        instructionsController.text.isNotEmpty &&
                        _categoriaSeleccionada != null &&
                        _imagenSeleccionada != null) {
                      widget.agregarRecetaCallback(
                        nameController.text,
                        instructionsController.text,
                        widget.autor,
                        _categoriaSeleccionada!,
                        _imagenSeleccionada!,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor complete todos los campos.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(kColorBoton),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Agregar Receta',
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
