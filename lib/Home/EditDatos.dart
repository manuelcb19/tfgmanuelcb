import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/CustomViews/CustomButton.dart';
import 'package:tfgmanuelcb/CustomViews/CustomTextField.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

import '../FirebaseObjects/FbUsuario.dart';

class EditDatos extends StatefulWidget {
  @override
  _EditDatosState createState() => _EditDatosState();
}

class _EditDatosState extends State<EditDatos> {
  TextEditingController tecNombre = TextEditingController();
  TextEditingController tecApellidos = TextEditingController();
  FbUsuario perfil = FbUsuario(nombre: "nombre", apellidos: "apellidos", id: "id", shint: "shint");
  String _selectedImageUrl = "";
  bool mostrarPredefinida = true;
  DataHolder conexion = DataHolder();

  @override
  void initState() {
    super.initState();
    conseguirUsuario();
  }

  Future<void> conseguirUsuario() async {
    try {
      FbUsuario perfil = await conexion.fbadmin.conseguirUsuario();
      setState(() {
        this.perfil = perfil;
        tecNombre.text = perfil.nombre;
        tecApellidos.text = perfil.apellidos;
        _selectedImageUrl = perfil.shint; // Asume que 'shint' es la URL de la imagen
        mostrarPredefinida = false; // Ocultar imagen predefinida si ya hay una imagen de perfil
      });
    } catch (e) {
      print("Error al obtener el perfil del usuario: $e");
    }
  }

  void onClickAceptar() async {
    setState(() {
      mostrarPredefinida = false;
    });
    DataHolder().fbadmin.anadirUsuario(
        tecNombre.text, tecApellidos.text, _selectedImageUrl);
    Navigator.of(context).popAndPushNamed("/homeview");
  }

  Future<void> _showImageDialog(BuildContext context) async {
    List<String> imageUrls = await obtenerImagenesDesdeFirebase();
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
                      height: 100,
                      width: 100,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  if (!mostrarPredefinida)
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(_selectedImageUrl),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: customTextField(
                  tecUsername: tecNombre,
                  oscuro: false,
                  sHint: "Introduzca su nombre",
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: customTextField(
                  tecUsername: tecApellidos,
                  oscuro: false,
                  sHint: "Introduzca sus apellidos",
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
              CustomButton(texto: "Aceptar", onPressed: onClickAceptar),
            ],
          ),
        ),
      ),
    );
  }
}