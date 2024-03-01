import 'package:cloud_firestore/cloud_firestore.dart';

class FbPartidas {
  String? nombre;
  int? puntuacion;
  int? orden;

  FbPartidas({
    this.puntuacion,
    this.nombre,
    this.orden,
  });

  factory FbPartidas.fromFirestore(DocumentSnapshot<Map<String, dynamic>> partidaDoc) {
    final data = partidaDoc.data();

    if (data != null && data.containsKey("partidas")) {
      final partidasData = data["partidas"] as Map<String, dynamic>;

      final entry = partidasData.entries.first;

      return FbPartidas(
        nombre: entry.key,
        puntuacion: entry.value["puntuacion"],
        orden: entry.value["orden"],
      );
    } else {
      throw Exception("La clave 'partidas' no existe en los datos del documento.");
    }
  }
}
