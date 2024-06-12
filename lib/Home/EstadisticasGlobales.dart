import 'package:flutter/material.dart';
import '../Singletone/FirebaseAdmin.dart';

class EstadisticasGlobales extends StatefulWidget {
  @override
  _EstadisticasGlobalesState createState() => _EstadisticasGlobalesState();
}

class _EstadisticasGlobalesState extends State<EstadisticasGlobales> {
  FirebaseAdmin firebaseAdmin = FirebaseAdmin();
  Map<String, dynamic>? estadisticas;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerEstadisticas();
  }

  Future<void> obtenerEstadisticas() async {
    try {
      Map<String, dynamic> stats = await firebaseAdmin.obtenerEstadisticasGlobales();
      setState(() {
        estadisticas = stats;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas Globales'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : estadisticas == null || estadisticas!.containsKey('error')
          ? Center(child: Text('No hay datos disponibles'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Juego con más partidas: ${estadisticas!['juegoConMasPartidas']} (${estadisticas!['maxPartidas']} partidas)'),
            SizedBox(height: 8),
            Text('Juego con más puntos: ${estadisticas!['juegoConMasPuntos']} (${estadisticas!['maxPuntos']} puntos)'),
            SizedBox(height: 8),
            Text('Juego con más victorias: ${estadisticas!['juegoConMasVictorias']} (${estadisticas!['maxVictorias']} victorias)'),
            SizedBox(height: 8),
            Text('Juego con menos partidas: ${estadisticas!['juegoConMenosPartidas']} (${estadisticas!['minPartidas']} partidas)'),
            SizedBox(height: 8),
            Text('Juego con menos puntos: ${estadisticas!['juegoConMenosPuntos']} (${estadisticas!['minPuntos']} puntos)'),
          ],
        ),
      ),
    );
  }
}