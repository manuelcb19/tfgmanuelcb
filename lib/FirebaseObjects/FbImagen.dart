import 'package:cloud_firestore/cloud_firestore.dart';

class FbImagen{
  final String imagen;
  final String contenido;

  FbImagen({
    required this.imagen,
    required this.contenido,
  });

  factory FbImagen.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return FbImagen(

      imagen: data?['imagen'] != null ? data!['imagen'] : "",
      contenido: data?['contenido'] ?? "",

    );
  }

  FbImagen copyWith({
    String? nombre,
    String? contenido,
  }) {
    return FbImagen(

        imagen: imagen ?? this.imagen,
        contenido: contenido ?? this.contenido,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "imagen": imagen,
      "contenido": contenido,

    };
  }
}
