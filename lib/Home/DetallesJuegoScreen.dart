import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';

class DetallesJuegoScreen extends StatefulWidget {
  final FbBoardGame? juego;

  DetallesJuegoScreen({this.juego});

  @override
  _DetallesJuegoScreenState createState() => _DetallesJuegoScreenState();
}

class _DetallesJuegoScreenState extends State<DetallesJuegoScreen> {
  final List<FbBoardGame> juegos = [];

  void descargarJuegos() async {
    juegos.clear();
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    QuerySnapshot<Map<String, dynamic>> juegosSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(widget.juego?.id.toString())
        .collection("partidas")
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
        title: Text('Detalles del Juego'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.juego != null)
            Image.network(
              widget.juego!.sUrlImg,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.juego != null)
                  Text(
                    widget.juego!.nombre,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                if (widget.juego != null)
                  Text(
                    'Año de Publicación: ${widget.juego!.yearPublished}',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartidasScreen(idJuego: widget.juego!.id.toString()),
                      ),
                    );
                  },
                  child: Text('Ver Partidas'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartidasScreen(idJuego: widget.juego!.id.toString()),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
