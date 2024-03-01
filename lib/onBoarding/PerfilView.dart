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

  void onClickAceptar() async {
    setState(() {
      mostrarPredefinida = false;
    });

    conexion.fbadmin.anadirUsuario(tecNombre.text, tecApellidos.text, _selectedImageUrl);
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
          content: Column(
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
                    height: 100, // Ajusta la altura según tus necesidades
                    width: 100, // Ajusta el ancho según tus necesidades
                    fit: BoxFit.cover,
                  ),
                ),
            ],
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
        // Obtén los datos del documento
        Map<String, dynamic> data = imagenPerfilDoc.data() ?? {};

        // Itera sobre los valores del documento
        data.forEach((key, value) {
          // Verifica si el valor es de tipo String y no está vacío
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

  Future<List<Map<String, dynamic>>> descargarPartidas(FbBoardGame? juego) async {
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

  Future<String?> _showSearchDialog(BuildContext context, TextEditingController searchController,)
  async {
    TextEditingController _searchController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar Juego'),
          content: Column(
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
          actions: [
            TextButton(
              child: Text('Buscar'),
              onPressed: () async {
                String nombreJuego = _searchController.text.trim();

                Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuego);

                // Muestra una lista de IDs y permite al usuario seleccionar uno
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
                                await conexion.fbadmin.agregarJuegoDeMesaAlUsuario(id.toString(),diccionario[id]!);
                                Navigator.of(context).pop(id.toString());
                              },
                            ),
                        ],
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
                if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 500,
            minHeight: 700,
            maxWidth: 1000,
            maxHeight: 900,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                child: customTextField(
                  tecUsername: tecNombre,
                  oscuro: false,
                  sHint: "Introduzca su usuario",
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                child: customTextField(
                  tecUsername: tecApellidos,
                  oscuro: false,
                  sHint: "Introduzca su apellidos",
                ),
              ),
              Column(
                children: [
                  if (!mostrarPredefinida)
                    Image.network(
                      _selectedImageUrl,
                      width: 300,
                      height: 450,
                    ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _showImageDialog(context);
                    },
                    child: Text('Seleccionar Imagen de perfil'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showSearchDialog(context, tecNombre);
                    },
                    child: Text('Añadir Juegos de Mesa'),
                  ),
                  SizedBox(height: 16), // Espacio vertical
                  CustomButton(texto: "aceptar", onPressed: onClickAceptar),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
