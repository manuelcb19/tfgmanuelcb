
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

import '../CustomViews/CustomTextField.dart';


class DetallesJuegoScreen extends StatefulWidget {

  DataHolder conexion = DataHolder();


  @override
  _DetallesJuegoScreenState createState() => _DetallesJuegoScreenState();
}

class _DetallesJuegoScreenState extends State<DetallesJuegoScreen> {
  DataHolder conexion = DataHolder();
  List<Map<String, dynamic>> partidasList = [];
  late FbBoardGame? juego;
  TextEditingController tecNombre = TextEditingController();
  TextEditingController tecPuntuacion = TextEditingController();

  @override
  void initState() {
    super.initState();
    juego = conexion.juego;
    descargarPartidas();
  }

  void descargarPartidas() async {

    partidasList.clear();
    partidasList = await conexion.fbadmin.descargarPartidas(juego);
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
                conexion.fbadmin.modificarPartida(juego, orden, nuevoNombre, nuevaPuntuacion);
                Future.delayed(Duration(seconds: 2), () {
                  descargarPartidas();
                  Navigator.of(context).pop();
                  callback();
                });
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
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/estadisticas');
            },
          ),
        ],
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (juego?.sUrlImg != null)
            Image.network(
              juego!.sUrlImg!,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              juego?.nombre ?? 'Nombre del Juego',
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
              Future.delayed(Duration(seconds: 2), () {
                descargarPartidas();
              });
            });
          },
          child: Icon(Icons.arrow_forward),
        ),
    );
  }
}
