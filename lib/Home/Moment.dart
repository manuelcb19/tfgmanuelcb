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
  File _imagePreview = File("");
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

    print("RUTA DONDE VA A GUARDARSE LA IMAGEN: $rutaEnNube");

    final rutaAFicheroEnNube = storageRef.child(rutaEnNube);
    print("La ruta donde se va a guardar en la nube es: " + rutaAFicheroEnNube.toString());

    final metadata = SettableMetadata(contentType: "image/jpeg");

    try {
      await rutaAFicheroEnNube.putFile(_imagePreview, metadata);
      print("SE HA SUBIDO LA IMAGEN");

      String url = await rutaAFicheroEnNube.getDownloadURL();
      print("URL de la imagen: $url");

      return url;
    } on FirebaseException catch (e) {
      print("ERROR AL SUBIR IMAGEN: " + e.toString());
      print("STACK TRACE: " + e.stackTrace.toString());
      print("RUTA DEL ARCHIVO: $rutaEnNube");
      return "no funciona";
    }
  }

  Future<void> addMemory(String contenido, String imageUrl) async {
    print("hasta aqui ha llegado");
    try {
      print("hasta aqui ha llegado");
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
      List<FbImagen> imagenesDescargadas = await conexion.fbadmin.descargarMemories(userId);
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
    print("el titulo del post es : " + contenido.toString());
    print("la imagen es: " + _imagePreview.toString());
    if (_imagePreview != null && _imagePreview.existsSync()) {
      try {
        String imageUrl = await setearUrlImagen();
        print("URL de la imagen: $imageUrl");

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
    print("FFFFFFFFFFFFFFFFFFFFF" + imagenes[index].imagen.toString());
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
          content: Column(
            children: [
              customTextField(
                tecUsername: tecPost,
                oscuro: false,
                sHint: "Título del momento",
              ),
              ElevatedButton(
                onPressed: () => onGalleryClicked(),
                child: Text("Desde galería"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Puedes cambiar el color del botón
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String titulo = tecPost.text;
                if (_imagePreview != null && titulo.isNotEmpty) {
                  print("Título seleccionado: $titulo");
                  print(_imagePreview.toString() + "Esta es la imagen");
                  String imageUrl = await setearUrlImagen();
                  print(imageUrl.toString());
                  await addMemory(titulo, imageUrl);
                  setState(() {});
                } else {
                  print("Seleccione una imagen y un título antes de subir el post.");
                }
              },
              child: Text("Subir"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Puedes cambiar el color del botón
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
        title: Text(DataHolder().sNombre),
        backgroundColor: Colors.blue, // Puedes cambiar el color del app bar según tus preferencias
      ),
      body: Container(
        color: Colors.grey[200], // Fondo gris claro para el cuerpo
        child: Center(
          child: Lista(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogo,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Puedes cambiar el color del botón flotante
      ),
    );
  }
}
