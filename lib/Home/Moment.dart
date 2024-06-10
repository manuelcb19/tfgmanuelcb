import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../CustomViews/CustomCellView.dart';
import '../CustomViews/CustomTextField.dart';
import '../FirebaseObjects/FbImagen.dart';
import '../Singletone/DataHolder.dart';

class Moment extends StatefulWidget {
  @override
  _MomentViewState createState() => _MomentViewState();
}

class _MomentViewState extends State<Moment> {
  TextEditingController tecPost = TextEditingController();
  DataHolder conexion = DataHolder();
  FirebaseFirestore db = FirebaseFirestore.instance;
  ImagePicker _picker = ImagePicker();
  File? _imagePreview;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  List<FbImagen> imagenes = [];

  @override
  void initState() {
    super.initState();
    descargarMemories();
  }

  void onCameraClicked() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePreview = File(image.path);
      });
    }
  }

  void onGalleryClicked() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePreview = File(image.path);
      });
    }
  }

  Future<String> setearUrlImagen() async {
    final storageRef = FirebaseStorage.instance.ref();
    String rutaEnNube =
        "memory/" + userId + "/memories/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

    final rutaAFicheroEnNube = storageRef.child(rutaEnNube);

    final metadata = SettableMetadata(contentType: "image/jpeg");

    try {
      await rutaAFicheroEnNube.putFile(_imagePreview!, metadata);

      String url = await rutaAFicheroEnNube.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      print("ERROR AL SUBIR IMAGEN: " + e.toString());
      return "no funciona";
    }
  }

  Future<void> addMemory(String contenido, String imageUrl) async {
    try {
      await db.collection("memory").doc(userId).collection("memories").add({
        "contenido": contenido,
        "imagen": imageUrl.toString(),
      });
    } catch (e) {
      print("Error al agregar memoria: $e");
    }
  }

  Future<void> descargarMemories() async {
    try {
      List<FbImagen> imagenesDescargadas = (await conexion.fbadmin.descargarMemories(userId)).cast<FbImagen>();
      setState(() {
        imagenes = imagenesDescargadas;
      });

      print("Número de imágenes descargadas: ${imagenes.length}");
    } catch (e) {
      print("Error al descargar memorias: $e");
    }
  }

  Future<void> subirLaImagen() async {
    String contenido = tecPost.text;
    if (_imagePreview != null && _imagePreview!.existsSync()) {
      try {
        String imageUrl = await setearUrlImagen();

        if (imageUrl.isNotEmpty) {
          await addMemory(contenido, imageUrl);
          await descargarMemories();
          print("Imagen subida correctamente.");
        } else {
          print("Error al obtener la URL de la imagen.");
        }
      } catch (e) {
        print("Error al subir la imagen: $e");
      }
    } else {
      print("Seleccione una imagen antes de subir el post.");
    }
  }

  Widget creadorDeSeparadorLista(BuildContext context, int index) {
    return Divider();
  }

  Widget creadorDeItemLista(BuildContext context, int index) {
    return CustomCellView(sTexto: imagenes[index].contenido, imagen: imagenes[index].imagen);
  }

  Widget Lista() {
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: imagenes.length,
      itemBuilder: creadorDeItemLista,
      separatorBuilder: creadorDeSeparadorLista,
    );
  }

  void _mostrarDialogo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subir Imagen"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                customTextField(
                  tecUsername: tecPost,
                  oscuro: false,
                  sHint: "Título del momento",
                ),
                SizedBox(height: 16),
                if (_imagePreview != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _imagePreview!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => onCameraClicked(),
                  child: Text("Desde la cámara"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onGalleryClicked(),
                  child: Text("Desde galería"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String titulo = tecPost.text;
                if (_imagePreview != null && titulo.isNotEmpty) {
                  String imageUrl = await setearUrlImagen();

                  await Future.delayed(Duration(seconds: 2), () {
                    addMemory(titulo, imageUrl);
                    descargarMemories();
                    setState(() {});
                  });

                } else {
                  print("Seleccione una imagen y un título antes de subir el post.");
                }
              },
              child: Text("Subir"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Lista(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogo,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}