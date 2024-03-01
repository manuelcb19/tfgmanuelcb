import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

import '../CustomViews/CustomTextField.dart';
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
  TextEditingController tecNombre = TextEditingController();
  TextEditingController tecPuntuacion = TextEditingController();

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

  void _showDetailsDialog(int orden, VoidCallback callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Partida'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              customTextField(tecUsername: tecNombre, oscuro: false, sHint: "Nombre de puntuacion a cambiar",),
              customTextField(tecUsername: tecPuntuacion, oscuro: false, sHint: "Introduzca la puntuacion nueva",),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {

                String nuevoNombre = tecNombre.text;
                int nuevaPuntuacion = int.parse(tecPuntuacion.text);

                conexion.fbadmin.modificarPartida(widget.juego, orden, nuevoNombre, nuevaPuntuacion);
                Navigator.of(context).pop();
                callback();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus partidas'),
        shadowColor: Colors.black,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white10,
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
                  onTap: () {
                    _showDetailsDialog(partidasList[index]['orden'], descargarPartidas);
                  },
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
