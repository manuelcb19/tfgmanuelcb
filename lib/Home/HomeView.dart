import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<FbBoardGame> juegos = [];

  @override
  void initState() {
    super.initState();
    descargarJuegos();
  }

  void descargarJuegos() async {
    juegos.clear();

    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid; // Reemplaza con tu lógica para obtener el ID del usuario

    QuerySnapshot<Map<String, dynamic>> juegosSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .get();

    juegosSnapshot.docs.forEach((juegoDoc) {
      FbBoardGame juego = FbBoardGame.fromFirestore(juegoDoc, null);
      juegos.add(juego);
    });

    setState(() {}); // Actualizar la interfaz de usuario después de descargar los juegos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Juegos'),
      ),
      body: ListView.builder(
        itemCount: juegos.length,
        itemBuilder: (context, index) {
          FbBoardGame juego = juegos[index];
          return ListTile(
            title: Text(juego.nombre),
            subtitle: Text('Año de Publicación: ${juego.yearPublished}'),

            // Aquí puedes mostrar la imagen si es necesario
            // Para mostrar una imagen desde una URL, puedes usar Image.network(juego.sUrlImg)
          );
        },
      ),
    );
  }
}
