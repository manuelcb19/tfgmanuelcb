import 'dart:io';
import 'package:bgg_api/bgg_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfgmanuelcb/CustomViews/CustomButton.dart';
import 'package:tfgmanuelcb/CustomViews/CustomTextField.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class PerfilView extends StatefulWidget {
  @override
  _PerfilViewState createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  String? selectedGameId;
  String _selectedImageUrl = "";
  TextEditingController tecNombre = TextEditingController();
  TextEditingController tecApellidos = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late BuildContext _context;
  DataHolder conexion = DataHolder();
  String imagenPredefinida = "resources/imagenpredefinida.png";
  bool mostrarPredefinida = true;
  List<BoardGame> listaJuegos = [];
  int idJuego = 0;

  void onClickAceptar() async {
    setState(() {
      mostrarPredefinida = false;
    });
    conexion.fbadmin.agregarJuegosDeMesaAlUsuarioLista(listaJuegos);
    conexion.fbadmin.anadirUsuario(
        tecNombre.text, tecApellidos.text, _selectedImageUrl);
    Navigator.of(_context).popAndPushNamed("/homeview");
  }

  Future<void> _showImageDialog(BuildContext context) async {
    List<String> imageUrls = await obtenerImagenesDesdeFirebase();
    print(imageUrls.length);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Imagen'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (String url in imageUrls)
                  InkWell(
                    onTap: () {
                      setState(() {
                        mostrarPredefinida = false;
                        _selectedImageUrl = url;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Image.network(
                      url,
                      height: 50, // Reduced height
                      width: 50,  // Reduced width
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> obtenerImagenesDesdeFirebase() async {
    List<String> imageUrls = [];
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      DocumentSnapshot<Map<String, dynamic>> imagenPerfilDoc = await db
          .collection("Imagenes")
          .doc("imagenperfil")
          .get();

      if (imagenPerfilDoc.exists) {
        Map<String, dynamic> data = imagenPerfilDoc.data() ?? {};

        data.forEach((key, value) {
          if (value is String && value.isNotEmpty) {
            imageUrls.add(value);
          }
        });
      }

      return imageUrls;
    } catch (e) {
      print("Error al obtener imágenes desde Firebase: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> descargarPartidas(
      FbBoardGame? juego) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Map<String, dynamic>> partidasList = [];
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> partidasSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juego?.id.toString())
        .collection("partidas")
        .get();

    partidasList.clear();
    for (var doc in partidasSnapshot.docs) {
      Map<String, dynamic> partidaData = doc.data() as Map<String, dynamic>;
      partidasList.add(partidaData);
    }

    return partidasList;
  }

  Future<String?> _showSearchDialog(BuildContext context,
      TextEditingController searchController,) async {
    TextEditingController _searchController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar Juego'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese el nombre del juego',
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Buscar'),
              onPressed: () async {
                String nombreJuego = _searchController.text.trim();

                Map<int, String> diccionario = await conexion.httpAdmin
                    .obtenerDiccionarioDeIds(nombreJuego);

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
                                  BoardGame? juego = await conexion.fbadmin.ConsultarJuego(id.toString());
                                  if (juego != null) {
                                    setState(() {
                                      listaJuegos.add(juego);
                                    });
                                  }
                                  Navigator.of(context).pop(id.toString());
                                },
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                if (selectedIdFromList != null &&
                    selectedIdFromList.isNotEmpty) {
                  print("ID seleccionada: $selectedIdFromList");
                  Navigator.of(context).pop(selectedIdFromList);
                } else {
                  print("error al seleccionar el juego");
                }
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      customTextField(
                        tecUsername: tecNombre,
                        oscuro: false,
                        sHint: "Introduzca su usuario",
                      ),
                      SizedBox(height: 16),
                      customTextField(
                        tecUsername: tecApellidos,
                        oscuro: false,
                        sHint: "Introduzca su apellido",
                      ),
                      SizedBox(height: 16),
                      if (!mostrarPredefinida)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            _selectedImageUrl,
                            width: 150, // Reduced width
                            height: 225, // Reduced height
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await _showImageDialog(context);
                        },
                        child: Text('Seleccionar Imagen de perfil'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showSearchDialog(context, tecNombre);
                        },
                        child: Text('Añadir Juegos de Mesa'),
                      ),
                      SizedBox(height: 16),
                      CustomButton(texto: "Aceptar", onPressed: onClickAceptar),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (BoardGame elemento in listaJuegos)
                      GestureDetector(
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context, elemento);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            width: 120,
                            padding: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: Text(
                              elemento.name ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, BoardGame game) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Desea borrar este juego de la lista?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  listaJuegos.remove(game);
                });
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}