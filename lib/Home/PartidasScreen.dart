import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Singletone/DataHolder.dart';
import 'DetallesJuegoScreen.dart';

class PartidasScreen extends StatefulWidget {

  String idJuego = DataHolder().juego.id.toString();


  @override
  _PartidasScreenState createState() => _PartidasScreenState();
}

class _PartidasScreenState extends State<PartidasScreen> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> partidasTemp = [];
  DataHolder conexion = DataHolder();
  String nombre = '';


  Future<void> cargarJuego() async {
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      nombre = conexion.juego.id.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partidas'),
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _agregarPartida,
                child: Text('Agregar Jugador'),
              ),
              ElevatedButton(
                onPressed: () {
                  _agregarPartidasFirestore();
                  Navigator.of(context).pop(); // Cerrar el AlertDialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DetallesJuegoScreen()),
                  );
                },
                child: Text('Agregar Partida al Juego'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: partidasTemp.length,
              itemBuilder: (context, index) {
                String nombre = partidasTemp[index]["nombre"];
                int puntuacion = partidasTemp[index]["puntuacion"];
                return ListTile(
                  title: Text(nombre),
                  subtitle: Text('Puntuación: $puntuacion'),
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
              onPressed: () async {
                  setState(() {
                    partidasTemp.add({
                      "nombre": nombre,
                      "puntuacion": puntuacion,
                    });
                  });
                  Navigator.of(context).pop();
              },
              child: Text('Agregar a lista temporal'),
            ),
          ],
        );
      },
    );
  }

  void _agregarPartidasFirestore() async {
    if (partidasTemp.isNotEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      try {

        DocumentReference<Map<String, dynamic>> juegoRef = db
            .collection("ColeccionJuegos")
            .doc(uid)
            .collection("juegos")
            .doc(widget.idJuego);

        CollectionReference<Map<String, dynamic>> partidasRef =
        juegoRef.collection("partidas");

        QuerySnapshot<Map<String, dynamic>> snapshot =
        await partidasRef.orderBy('orden', descending: true).limit(1).get();

        int nuevoOrden = 1;

        if (snapshot.docs.isNotEmpty) {
          nuevoOrden = (snapshot.docs.first['orden'] as int) + 1;
        }

        await partidasRef.add({
          "partidas": Map.fromEntries(partidasTemp.map((e) =>
              MapEntry<String, dynamic>(e['nombre'] as String, e['puntuacion']))),
          "orden": nuevoOrden,
        });

        setState(() {
          partidasTemp = [];
        });

        print("Partida agregada a Firestore con orden $nuevoOrden");
      } catch (error) {
        print("Error al agregar la partida a Firestore: $error");
      }
    } else {
      print("La lista de partidas está vacía");
    }
  }
}