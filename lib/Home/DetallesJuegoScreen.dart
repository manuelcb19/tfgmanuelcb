import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';
// Asegúrate de que las rutas de importación sean correctas para tu proyecto.

class DetallesJuegoScreen extends StatefulWidget {
  final FbBoardGame? juego;

  DetallesJuegoScreen({this.juego});

  @override
  _DetallesJuegoScreenState createState() => _DetallesJuegoScreenState();
}

class _DetallesJuegoScreenState extends State<DetallesJuegoScreen> {
  final List<Map<String, dynamic>> partidasList = [];

  void descargarPartidas() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> partidasSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(widget.juego?.id.toString())
        .collection("partidas")
        .get();

    partidasList.clear();
    for (var doc in partidasSnapshot.docs) {
      Map<String, dynamic> partidaData = doc.data() as Map<String, dynamic>;
      partidasList.add(partidaData);
    }

    setState(() {}); // Actualizar la interfaz de usuario después de descargar los datos
  }

  @override
  void initState() {
    super.initState();
    descargarPartidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.juego?.nombre ?? 'Detalles del Juego'),
      ),
      body: Column(
        children: [
          if (widget.juego?.sUrlImg != null)
            Image.network(
              widget.juego!.sUrlImg!,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.juego?.nombre ?? 'Nombre del Juego',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: partidasList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> partida = partidasList[index];
                return ListTile(
                  title: Text('Partida ${index + 1}'),
                  subtitle: Text(partida.entries.map((e) => '${e.key}: ${e.value}').join(', ')),
                );
              },
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