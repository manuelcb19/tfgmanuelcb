import 'package:cloud_firestore/cloud_firestore.dart';

class FbUsuario {
  String nombre;
  String apellidos;
  String id;
  String shint;

  FbUsuario({
    required this.nombre,
    required this.apellidos,
    required this.id,
    required this.shint,
  });

  factory FbUsuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return FbUsuario(
      shint: data?['shint'] ?? "",
      nombre: data?['nombre'] ?? "",
      id: data?['id'] ?? "",
      apellidos: data?['apellidos'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "shint": shint,
      "nombre": nombre,
      "id": id,
      "apellidos": apellidos,
    };
  }
}
