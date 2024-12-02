import 'package:cloud_firestore/cloud_firestore.dart';

class FsService {
  Stream<QuerySnapshot> recetas() {
    return FirebaseFirestore.instance.collection('recetas').snapshots();
  }


  Future<void> agregarReceta(String nombre, String intrucciones, String autor, String categoria, String imagen) {
    return FirebaseFirestore.instance.collection('recetas').add({
      'nombre': nombre,
      'intrucciones':intrucciones,
      'autor':autor,
      'categoria':categoria,
      'imagen':imagen
    });
  }


  Future<void> borrarReceta(String id) {
    return FirebaseFirestore.instance.collection('recetas').doc(id).delete();
  }
  Stream<QuerySnapshot> categoria() {
    return FirebaseFirestore.instance.collection('categorias').snapshots();
  }


}