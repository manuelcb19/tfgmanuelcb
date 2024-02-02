import 'dart:io';
import 'package:bgg_api/bgg_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfgmanuelcb/CustomViews/CustomButton.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

import '../CustomViews/CustomTextField.dart';

class PerfilView extends StatefulWidget {
  @override
  _PerfilViewState createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController tecNombre = TextEditingController();
  TextEditingController tecApellidos = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late BuildContext _context;
  DataHolder conexion = DataHolder();
  ImagePicker _picker = ImagePicker();
  File _imagePreview = File("");
  String imagenPredefinida = "resources/imagenpredefinida.png";
  bool mostrarPredefinida = true; // Variable para controlar la visibilidad de la imagen predefinida

  void onClickAceptar() async {
    setState(() {
      mostrarPredefinida = false; // Después de seleccionar una nueva imagen, ocultar la predefinida
    });

    //String imageUrl = await setearUrlImagen();
    //print(imageUrl);
    conexion.fbadmin.anadirUsuario(tecNombre.text, tecApellidos.text, "gggg");
    Navigator.of(_context).popAndPushNamed("/homeview");
  }

  static Future<String?> _showSearchDialog(
      BuildContext context, TextEditingController searchController,
      ) async {
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

                // Lógica para obtener la lista de IDs usando tu función
                List<String> listaDeIds = await obtenerListaDeIds(nombreJuego);

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
                          for (String id in listaDeIds)
                            ListTile(
                              title: Text(id),
                              onTap: () {
                                Navigator.of(context).pop(id);
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

                // Resto del código
                if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
                  Navigator.of(context).pop(selectedIdFromList);
                } else {
                  // Mostrar mensaje o realizar otras acciones si es necesario
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

  static Future<List<String>> obtenerListaDeIds(String nombreJuego) async {
    try {
      var bgg = Bgg();
      var searchBoardGamesResult = await bgg.searchBoardGames(nombreJuego);

      if (searchBoardGamesResult.isNotEmpty) {
        return searchBoardGamesResult.map((boardGame) => boardGame.name.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      // Manejar errores aquí
      print("Error al obtener la lista de IDs: $e");
      return [];
    }
  }

  /*Future<void> _getImage() async {
    final picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _imagePreview = File(pickedImage.path);
        mostrarPredefinida = false; // Después de seleccionar una nueva imagen, ocultar la predefinida
      });
    }
  }*/
/*
  Future<String> setearUrlImagen() async {
    final storageRef = FirebaseStorage.instance.ref();

    String rutaEnNube =
        "posts/" + FirebaseAuth.instance.currentUser!.uid + "/imgs/" +
            DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    print("RUTA DONDE VA A GUARDARSE LA IMAGEN: " + rutaEnNube);

    final rutaAFicheroEnNube = storageRef.child(rutaEnNube);

    final metadata = SettableMetadata(contentType: "image/jpeg");
    try {
      await rutaAFicheroEnNube.putFile(_imagePreview, metadata);

      print("SE HA SUBIDO LA IMAGEN");

      // Obtén la URL de la imagen después de subirla
      String url = await rutaAFicheroEnNube.getDownloadURL();
      print("URL de la imagen: $url");
      return url;
    } on FirebaseException catch (e) {
      print("ERROR AL SUBIR IMAGEN: " + e.toString());
      print("STACK TRACE: " + e.stackTrace.toString());
      return "";
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    this._context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        shadowColor: Colors.orangeAccent,
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.amber[200],
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
                  if (mostrarPredefinida)
                    Image.asset(
                      imagenPredefinida,
                      width: 300,
                      height: 450,
                    ),
                  if (_imagePreview != null && !mostrarPredefinida)
                    Image.file(
                      _imagePreview,
                      height: 200, // Ajusta la altura según tus necesidades
                      width: 200, // Ajusta el ancho según tus necesidades
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      //await _getImage();
                    },
                    child: Text('Seleccionar Imagen desde Galería'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Aquí debes abrir el diálogo para introducir el nombre del juego
                      _showSearchDialog(context, _searchController);
                    },
                    child: Text('Añadir Juegos de Mesa'),
                  ),
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
