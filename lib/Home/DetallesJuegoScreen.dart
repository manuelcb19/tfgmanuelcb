import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
// Asegúrate de que las rutas de importación sean correctas para tu proyecto.

class DetallesJuegoScreen extends StatefulWidget {

  DataHolder conexion = DataHolder();
  late FbBoardGame? juego;

  @override
  _DetallesJuegoScreenState createState() => _DetallesJuegoScreenState();
}

class _DetallesJuegoScreenState extends State<DetallesJuegoScreen> {
  DataHolder conexion = DataHolder();
  List<Map<String, dynamic>> partidasList = [];

  @override
  void initState() {
    super.initState();
    widget.juego = conexion.juego;
    cargarJuego();

  }

  Future<void> cargarJuego() async {
    await conexion.fbadmin.descargarPartidas(conexion.juego).then((partidas) {
      setState(() {
        partidasList = partidas;
      });
    });
  }

  void descargarPartidas() async {

    partidasList.clear();
    partidasList = await conexion.fbadmin.descargarPartidas(widget.juego);
    setState(() {});
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
              style: Theme.of(context).textTheme.titleLarge,
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
          Navigator.pushNamed(context, '/partidasscreen', arguments: {}).then((_) {
            // Esta parte se ejecutará cuando regreses de PartidasScreen
            descargarPartidas();
          });
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
