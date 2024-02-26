import 'package:cloud_firestore/cloud_firestore.dart';

class FbPartidas {
  String? nombre;
  int? puntuacion;

  FbPartidas({
    this.puntuacion,
    this.nombre,
  });

  factory FbPartidas.fromFirestore(DocumentSnapshot<Map<String, dynamic>> partidaDoc) {
    final data = partidaDoc.data();

    if (data != null && data.containsKey("partidas")) {
      final partidasData = data["partidas"] as Map<String, dynamic>;

      final entry = partidasData.entries.first;

      return FbPartidas(
        nombre: entry.key,
        puntuacion: entry.value,
      );
    } else {

      throw Exception("La clave 'partidas' no existe en los datos del documento.");
    }
  }
}

class TuClaseDondeQuieresMostrar {
  void mostrarPartidas() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> partidasSnapshot = await db
        .collection("partida")
        .get();

    List<FbPartidas> partidasList = partidasSnapshot.docs.map((partidaDoc) {
      return FbPartidas.fromFirestore(partidaDoc);
    }).toList();

    for (var partida in partidasList) {
      print("Nombre: ${partida.nombre}, Puntuación: ${partida.puntuacion}");
    }
  }
}
