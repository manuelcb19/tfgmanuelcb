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
  TextEditingController tecTitulo = TextEditingController();
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

  void onGalleyClicked() async {
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
        "posts/$userId/imgs/${DateTime.now().millisecondsSinceEpoch}.jpg";
    print("RUTA DONDE VA A GUARDARSE LA IMAGEN: $rutaEnNube");

    final rutaAFicheroEnNube = storageRef.child(rutaEnNube);

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
      return "";
    }
  }

  Future<void> addMemory(String memoryText, String contenido, String imageUrl) async {
    try {
      await db.collection("memory")
          .doc(userId)
          .collection("memories")
          .add({
        "nombre": memoryText,
        "contenido": contenido,
        "imagen": imageUrl,
      });
    } catch (e) {
      print("Error al agregar memoria: $e");
    }
  }

  Future<void> descargarMemories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> memoriesSnapshot = await db
          .collection("memory")
          .doc(userId)
          .collection("memories")
          .get();

      setState(() {
        imagenes = memoriesSnapshot.docs
            .map((doc) => FbImagen.fromFirestore(doc, null))
            .toList();
      });
    } catch (e) {
      print("Error al descargar memorias: $e");
    }
  }

  Future<void> subirElPost() async {
    String memoryText = tecTitulo.text;
    String contenido = tecPost.text;

    if (_imagePreview != null && memoryText.isNotEmpty && contenido.isNotEmpty) {
      String imageUrl = await setearUrlImagen();
      print("fffffffff"+imageUrl.toString());
      if (imageUrl.isNotEmpty) {
        await addMemory(memoryText, contenido, imageUrl);
        await descargarMemories();
        _imagePreview = File("");
        print("fffffffff");
      } else {
        print("Error al obtener la URL de la imagen.");
      }
    } else {
      print("Complete todos los campos antes de subir el post.");
    }
  }

  Widget creadorDeSeparadorLista(BuildContext context, int index) {
    return Divider();
  }

  Widget creadorDeItemLista(BuildContext context, int index) {
    print("FFFFFFFFFFFFFFFFFFFFF"+imagenes[index].imagen.toString());
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
    TextEditingController tecTituloDialogo = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subir Imagen"),
          content: Column(
            children: [
              customTextField(
                tecUsername: tecTituloDialogo,
                oscuro: false,
                sHint: "Título del momento",
              ),
              ElevatedButton(
                onPressed: () => onCameraClicked(),
                child: Text("Desde cámara"),
              ),
              ElevatedButton(
                onPressed: () => onGalleyClicked(),
                child: Text("Desde galería"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                String titulo = tecTituloDialogo.text;
                if (titulo.isNotEmpty) {
                  print("Título seleccionado: $titulo");
                  subirElPost();
                } else {
                  print("Ingrese un título antes de subir el post.");
                }
              },
              child: Text("Subir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DataHolder().sNombre)),
        body: Center(
          child: Lista(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _mostrarDialogo,
          child: Icon(Icons.add),
        ),
      );
  }
}