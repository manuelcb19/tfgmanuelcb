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

  int sumaValores = 1;
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

    print('Suma de valores: $sumaValores');
    print('Número total de partidas: $contadorPartidas');
    print('Número más grande: $numeroMasGrande');
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
            Text('Suma de Puntoos: $sumaValores'),
            Text("Número total de partidas:" + partidasList.length.toString()),
            Text('Media de Puntuacion: ${contadorPartidas > 0 ? sumaValores / contadorPartidas : 0}'),
            Text('Puntuacion más grande: $numeroMasGrande'),
            Text('Nombre de la Persona que mas ha ganado: $nombreGanador'),
          ],
        ),
      ),
    );
  }
}
