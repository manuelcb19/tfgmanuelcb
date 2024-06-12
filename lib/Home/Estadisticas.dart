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
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildStatisticCard(
                  icon: Icons.summarize,
                  label: 'Suma de Puntos total',
                  value: '$sumaValores',
                ),
                buildStatisticCard(
                  icon: Icons.list,
                  label: 'Número total de partidas',
                  value: '${partidasList.length}',
                ),
                buildStatisticCard(
                  icon: Icons.calculate,
                  label: 'Media de Puntuación',
                  value: '${contadorPartidas > 0 ? (sumaValores / contadorPartidas).toStringAsFixed(2) : 0}',
                ),
                buildStatisticCard(
                  icon: Icons.star,
                  label: 'Puntuación más Alta',
                  value: '$numeroMasGrande',
                ),
                buildStatisticCard(
                  icon: Icons.person,
                  label: 'Top winner',
                  value: '$nombreGanador',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatisticCard({required IconData icon, required String label, required String value}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurple),
            SizedBox(width: 8.0),
            Text(
              '$label: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}