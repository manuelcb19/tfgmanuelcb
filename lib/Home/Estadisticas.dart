import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class Estadisticas extends StatefulWidget {
  @override
  _EstadisticasViewState createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<Estadisticas> {
  DataHolder conexion = DataHolder();
  List<Map<String, dynamic>> partidasList = [];
  late FbBoardGame juego;

  int sumaValores = 0;
  int contadorPartidas = 0;
  int numeroMasGrande = 0;
  String nombreGanador = "";

  @override
  void initState() {
    super.initState();
    juego = conexion.juego;
    cargarEstadisticas();
  }

  void cargarEstadisticas() async {
    await descargarPartidas();
    producirEstadisticas();
  }

  Future<void> descargarPartidas() async {
    partidasList.clear();
    partidasList = await conexion.fbadmin.descargarPartidas(juego);
    setState(() {});
  }

  void producirEstadisticas() {
    sumaValores = 0;
    contadorPartidas = 0;
    numeroMasGrande = 0;
    nombreGanador = "";

    for (Map<String, dynamic> partida in partidasList) {
      if (partida.containsKey('partidas') && partida['partidas'] is Map<String, dynamic>) {
        Map<String, dynamic> partidas = partida['partidas'];

        partidas.forEach((clave, valor) {
          if (valor is int) {
            sumaValores += valor;
            contadorPartidas++;

            if (valor > numeroMasGrande) {
              numeroMasGrande = valor;
              nombreGanador = clave;
            }
          }
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.summarize),
                  SizedBox(width: 8.0),
                  Text('Suma de Puntos de todos los juegos: $sumaValores'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list),
                  SizedBox(width: 8.0),
                  Text('Número total de partidas: ${partidasList.length}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate),
                  SizedBox(width: 8.0),
                  Text('Media de Puntuación: ${contadorPartidas > 0 ? sumaValores / contadorPartidas : 0}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star),
                  SizedBox(width: 8.0),
                  Text('Puntuación más Alta: $numeroMasGrande'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8.0),
                  Text('Nombre de la persona que más Juegos ha ganado: $nombreGanador'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}