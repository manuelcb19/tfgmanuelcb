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
    return FbPartidas(
      puntuacion: data?['Campo2'],
      nombre: data?['Campo1'],
    );
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

    // Ahora, puedes recorrer la lista de partidas e imprimir o mostrar la información
    for (var partida in partidasList) {
      print("Nombre: ${partida.nombre}, Puntuación: ${partida.puntuacion}");
    }
  }
}
