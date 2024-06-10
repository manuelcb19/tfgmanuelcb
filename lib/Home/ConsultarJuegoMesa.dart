import 'package:bgg_api/bgg_api.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class ConsultarJuegoMesa extends StatefulWidget {
  @override
  _ConsultarJuegoMesaState createState() => _ConsultarJuegoMesaState();
}

class _ConsultarJuegoMesaState extends State<ConsultarJuegoMesa> {
  DataHolder conexion = DataHolder();
  BoardGame? boardGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta tu Juego'),
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (boardGame != null && boardGame!.image != null) _buildGameImage(),
            if (boardGame != null && boardGame!.name != null) _buildGameName(),
            if (boardGame != null) _buildGameDetails(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  String? nombreJuego = await conexion.dialogclass.showSearchDialog(context);
                  if (nombreJuego != null && nombreJuego.isNotEmpty) {
                    print("Nombre del juego seleccionado: $nombreJuego");
                    Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuego);
                    String? selectedIdFromList = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Lista de IDs'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int id in diccionario.keys)
                                  ListTile(
                                    title: Text(diccionario[id]!),
                                    onTap: () async {
                                      boardGame = await conexion.fbadmin.buscarJuegoMesa(id.toString(), diccionario[id]!);
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Aceptar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: Icon(Icons.search),
                label: Text('Buscar Juego de Mesa'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameImage() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(boardGame!.image!.toString(), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildGameName() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        boardGame!.name!,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGameDetails() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDetailItem('Año de Publicación', boardGame!.yearPublished.toString()),
          _buildDetailItem('Mínimo de Jugadores', boardGame!.minPlayers.toString()),
          _buildDetailItem('Máximo de Jugadores', boardGame!.maxPlayers.toString()),
          _buildDetailItem('Tiempo de Juego', '${boardGame!.playingTime} min'),
          _buildDetailItem('Tiempo Mínimo de Juego por Partida', '${boardGame!.minPlayTime} min'),
          _buildDetailItem('Tiempo Máximo de Juego por Partida', '${boardGame!.maxPlayTime} min'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}