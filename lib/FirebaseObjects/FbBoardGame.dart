import 'package:cloud_firestore/cloud_firestore.dart';

class FbBoardGame {
  final String nombre;
  final int yearPublished;
  final String sUrlImg;
  final int id;
  final int orden;

  FbBoardGame({
    required this.nombre,
    required this.yearPublished,
    required this.sUrlImg,
    required this.id,
    required this.orden
  });

  factory FbBoardGame.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return FbBoardGame(
      orden: data?['orden'] ?? 0,
      sUrlImg: data?['image'] != null ? data!['image'] : "",
      nombre: data?['nombre'] ?? "",
      yearPublished: data?['yearPublished'] ?? 0,
      id: data?['id'] ?? "",

    );
  }

  FbBoardGame copyWith({
    String? nombre,
    int? yearPublished,
    String? sUrlImg,
  }) {
    return FbBoardGame(
      orden: orden ?? this.orden,
      nombre: nombre ?? this.nombre,
      yearPublished: yearPublished ?? this.yearPublished,
      sUrlImg: sUrlImg ?? this.sUrlImg,
      id: id?? this.id
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "image": sUrlImg,
      "nombre": nombre,
      "yearPublished": yearPublished,
      "id": id,
    };
  }
}
