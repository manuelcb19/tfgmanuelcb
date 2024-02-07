import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';

class DetallesJuegoScreen extends StatelessWidget {
  FbBoardGame? juego;

  DetallesJuegoScreen({this.juego});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Juego'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (juego != null)
            Image.network(
              juego!.sUrlImg,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (juego != null)
                  Text(
                    juego!.nombre,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                if (juego != null)
                  Text(
                    'Año de Publicación: ${juego!.yearPublished}',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartidasScreen(),
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
              builder: (context) => PartidasScreen(),
            ),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
