import 'package:flutter/material.dart';

class PartidasScreen extends StatefulWidget {
  @override
  _PartidasScreenState createState() => _PartidasScreenState();
}

class _PartidasScreenState extends State<PartidasScreen> {
  List<Partida> partidas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partidas'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _agregarPartida();
            },
            child: Text('Agregar Partida'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: partidas.length,
              itemBuilder: (context, index) {
                Partida partida = partidas[index];
                return ListTile(
                  title: Text(partida.nombre),
                  subtitle: Text('Puntuación: ${partida.puntuacion}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _agregarPartida() {
    showDialog(
      context: context,
      builder: (context) {
        String nombre = '';
        int puntuacion = 0;

        return AlertDialog(
          title: Text('Agregar Partida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  nombre = value;
                },
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) {
                  puntuacion = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Puntuación'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Validar que se ingresen datos antes de agregar la partida
                if (nombre.isNotEmpty) {
                  Partida nuevaPartida = Partida(nombre: nombre, puntuacion: puntuacion);
                  setState(() {
                    partidas.add(nuevaPartida);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

class Partida {
  final String nombre;
  final int puntuacion;

  Partida({required this.nombre, required this.puntuacion});
}
