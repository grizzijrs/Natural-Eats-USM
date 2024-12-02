import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyectodam/constants.dart';
import 'package:proyectodam/pages/agregar_receta_page.dart';
import 'package:proyectodam/pages/detallesreceta_page.dart';
import 'package:proyectodam/services/fs_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FsService fsService = FsService();
  bool mostrarMisRecetas = false;

  Future<bool> _ConfirmacionCerrarSesion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirmar cierre de sesión"),
              content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Cerrar sesión"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _signOut(BuildContext context) async {
    bool confirmacion = await _ConfirmacionCerrarSesion(context);
    if (confirmacion) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<bool> _MostrarConfirmacionBorrar(BuildContext context) async {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Confirmar eliminación"),
                content: const Text(
                    "¿Estás seguro de que deseas eliminar esta receta?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Eliminar"),
                  ),
                ],
              );
            }) ??
        false;
  }

  void _eliminarReceta(
      BuildContext context, String id, String recetaUserId) async {
    if (widget.user.uid != recetaUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No tienes permiso para eliminar esta receta.')),
      );
      return;
    }

    bool confirmacion = await _MostrarConfirmacionBorrar(context);
    if (confirmacion) {
      try {
        await fsService.borrarReceta(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta eliminada con éxito.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la receta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(kInicioFondoDegradado),
      appBar: AppBar(
        backgroundColor: Color(kColorAppBar),
        toolbarHeight: 80,
        title: Row(
          children: [
            if (widget.user.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.photoURL!),
                radius: 25,
              ),
            const SizedBox(width: 15),
            Text(
              "Bienvenido ${widget.user.displayName ?? "Usuario"}",
              style: TextStyle(color: Color(kColorTexto), fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
                mostrarMisRecetas ? Icons.filter_alt_off : Icons.filter_alt,
                color: Color(kColorTexto)),
            onPressed: () {
              setState(() {
                mostrarMisRecetas = !mostrarMisRecetas;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(kColorTexto)),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fsService.recetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay recetas disponibles."));
          }

          final recetas = snapshot.data!.docs;

          final recetasFiltradas = mostrarMisRecetas
              ? recetas.where((receta) {
                  final recetaData = receta.data() as Map<String, dynamic>;
                  return recetaData['authorId'] == widget.user.uid;
                }).toList()
              : recetas;

          return ListView.builder(
            itemCount: recetasFiltradas.length,
            itemBuilder: (context, index) {
              final receta =
                  recetasFiltradas[index].data() as Map<String, dynamic>;
              final recetaId = recetasFiltradas[index].id;
              final recetaUserId = receta['authorId'];

              String imagenPath = receta['imagen'] ?? '';
              String categoria = receta['categoria'] ?? 'Sin categoría';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Color(kInicioFondoDegradado),
                child: ListTile(
                  title: Text(
                    receta['nombre'] ?? "Sin nombre",
                    style: TextStyle(color: Color(kColorTexto)),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Autor: ${receta['autor'] ?? "Desconocido"}",
                        style: TextStyle(color: Color(kColorTexto)),
                      ),
                      Text(
                        "Categoría: $categoria",
                        style: TextStyle(color: Color(kColorTexto)),
                      ),
                    ],
                  ),
                  leading: imagenPath.isNotEmpty
                      ? Image.asset(
                          'assets/images/$imagenPath',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.fastfood, color: Color(kColorTexto)),
                  trailing: widget.user.uid == recetaUserId
                      ? IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(kColorError)),
                          onPressed: () =>
                              _eliminarReceta(context, recetaId, recetaUserId),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallesrecetaPage(
                          receta: receta,
                          recetaId: recetaId,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Future.delayed(Duration(milliseconds: 100));

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarRecetaPage(
                autor: widget.user.displayName ?? "Anónimo",
                agregarRecetaCallback:
                    (nombre, instrucciones, autor, categoria, imagen) async {
                  try {
                    await FirebaseFirestore.instance.collection('recetas').add({
                      'nombre': nombre,
                      'instrucciones': instrucciones,
                      'autor': autor,
                      'categoria': categoria,
                      'imagen': imagen,
                      'authorId': widget.user.uid,
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al agregar la receta: $e')),
                    );
                  }
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(kColorBoton),
      ),
    );
  }
}
