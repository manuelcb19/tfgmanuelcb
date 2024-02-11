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

    // Asegúrate de que la clave "partidas" exista en los datos antes de acceder a sus elementos
    if (data != null && data.containsKey("partidas")) {
      final partidasData = data["partidas"] as Map<String, dynamic>;

      // Selecciona el primer elemento del mapa como nombre y el segundo como puntuación
      final entry = partidasData.entries.first;

      return FbPartidas(
        nombre: entry.key,
        puntuacion: entry.value,
      );
    } else {
      // Manejar el caso en que "partidas" no exista en los datos
      // Puedes lanzar una excepción, devolver un valor predeterminado, o manejarlo de otra manera según tus necesidades
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

    // Ahora, puedes recorrer la lista de partidas e imprimir o mostrar la información
    for (var partida in partidasList) {
      print("Nombre: ${partida.nombre}, Puntuación: ${partida.puntuacion}");
    }
  }
}
