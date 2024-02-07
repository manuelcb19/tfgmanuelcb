import 'package:cloud_firestore/cloud_firestore.dart';

class FbBoardGame {
  final String nombre;
  final int yearPublished;
  final String sUrlImg;

  FbBoardGame({
    required this.nombre,
    required this.yearPublished,
    required this.sUrlImg,
  });

  factory FbBoardGame.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return FbBoardGame(
      sUrlImg: data?['image'] != null ? data!['image'] : "",
      nombre: data?['nombre'] ?? "",
      yearPublished: data?['yearPublished'] ?? 0,
    );
  }

  FbBoardGame copyWith({
    String? nombre,
    int? yearPublished,
    String? sUrlImg,
  }) {
    return FbBoardGame(
      nombre: nombre ?? this.nombre,
      yearPublished: yearPublished ?? this.yearPublished,
      sUrlImg: sUrlImg ?? this.sUrlImg,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "image": sUrlImg,
      "nombre": nombre,
      "yearPublished": yearPublished,
    };
  }
}
