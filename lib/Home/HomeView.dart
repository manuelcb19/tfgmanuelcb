import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/CustomViews/CustomDrawer.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
import 'package:tfgmanuelcb/onBoarding/LoginView.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<FbBoardGame> juegos = [];
  TextEditingController _searchController = TextEditingController();
  DataHolder conexion = DataHolder();

  @override
  void initState() {
    super.initState();
    descargarJuegos();
  }

  void descargarJuegos() async {
    juegos.clear();

    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    QuerySnapshot<Map<String, dynamic>> juegosSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .get();

    juegosSnapshot.docs.forEach((juegoDoc) {
      FbBoardGame juego = FbBoardGame.fromFirestore(juegoDoc, null);
      juegos.add(juego);
    });

    setState(() {}); // Actualizar la interfaz de usuario después de descargar los juegos
  }

  void fHomeViewDrawerOnTap(int indice) async {
    print("---->>>> " + indice.toString());

    if (indice == 0) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginView()),
        ModalRoute.withName('/loginview'),
      );
    } else if (indice == 1) {
      Navigator.of(context).pushNamed(
        '/editarperfil',
        arguments: {},
      );

    }
    else if (indice == 2) {
      Navigator.of(context).pushNamed(
        '/consultarjuegomesa',
        arguments: {},
      );

    }
  }

  Future<void> _agregarJuegoDialog() async {
    String? selectedIdFromList = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String nombreJuegoBuscado = ''; // Variable para almacenar el nombre del juego a buscar

        return AlertDialog(
          title: Text('Buscar y Seleccionar Juego'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: nombreJuegoBuscado),
                onChanged: (value) {
                  nombreJuegoBuscado = value; // Actualizar el nombre del juego a buscar
                },
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre del juego',
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Lógica para obtener la lista de IDs usando tu función
                Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuegoBuscado);

                // Muestra una lista de nombres y permite al usuario seleccionar uno
                String? selectedIdFromList = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Lista de IDs'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int id in diccionario.keys)
                            ListTile(
                              title: Text(diccionario[id]!),
                              onTap: () async {
                                await conexion.fbadmin.agregarJuegoDeMesaAlUsuario(id.toString(), diccionario[id]!);
                                // Imprime el ID correspondiente al nombre seleccionado
                                print('ID seleccionado: $id');

                                Navigator.of(context).pop(id.toString());
                                descargarJuegos();
                              },
                            ),
                        ],
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

                // Resto del código...
                if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
                  print("ID seleccionada: $selectedIdFromList");
                  Navigator.of(context).pop(selectedIdFromList);
                } else {
                  // Mostrar mensaje o realizar otras acciones si es necesario
                }
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    // Resto del código...
    if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
      print("ID seleccionada: $selectedIdFromList");
      // Agregar el juego a la base de datos o realizar otras acciones según sea necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Juegos'),
      ),
      body: ListView.builder(
        itemCount: juegos.length,
        itemBuilder: (context, index) {
          FbBoardGame juego = juegos[index];
          return ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: juego.sUrlImg.isNotEmpty
                ? Image.network(
              juego.sUrlImg,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Container(),
            title: Text(juego.nombre),
            subtitle: Text('Año de Publicación: ${juego.yearPublished}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetallesJuegoScreen(juego: juego),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarJuegoDialog, // Asigna el método _agregarJuegoDialog al botón flotante
        child: Icon(Icons.add),
      ),
      drawer: CustomDrawer(onItemTap: fHomeViewDrawerOnTap, imagen: "hhhh",),
    );
  }
}
