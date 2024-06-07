import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Singletone/DataHolder.dart';
import 'DetallesJuegoScreen.dart';


class PartidasScreen extends StatefulWidget {
  final String idJuego = DataHolder().juego.id.toString();

  @override
  _PartidasScreenState createState() => _PartidasScreenState();
}

class _PartidasScreenState extends State<PartidasScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> partidasTemp = [];
  DataHolder conexion = DataHolder();
  String nombre = '';
  bool loading = false;

  Future<void> cargarJuego() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      nombre = conexion.juego.id.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    cargarJuego();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Gestión de Partidas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          if (loading)
            Center(child: CircularProgressIndicator())
          else if (partidasTemp.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No hay partidas registradas. Agrega una nueva partida para comenzar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: partidasTemp.length,
                itemBuilder: (context, index) {
                  String nombre = partidasTemp[index]["nombre"];
                  int puntuacion = partidasTemp[index]["puntuacion"];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          nombre[0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        nombre,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Puntuación: $puntuacion'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Acciones cuando se pulsa en la tarjeta
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _agregarPartida,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person_add),
            tooltip: 'Agregar Jugador',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              _agregarPartidasFirestore();
              setState(() {
                loading = true;
              });
              Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  loading = false;
                });
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DetallesJuegoScreen()),
                );
              });
            },
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.add),
            tooltip: 'Agregar Partida',
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
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  puntuacion = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Puntuación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
              ),
              onPressed: () {
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
          "partidas": Map.fromEntries(partidasTemp.map((e) => MapEntry<String, dynamic>(e['nombre'] as String, e['puntuacion']))),
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