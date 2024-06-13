

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../CustomViews/CustomButton.dart';
import '../CustomViews/CustomDialog.dart';
import '../CustomViews/CustomTextField.dart';
import '../Singletone/DataHolder.dart';


class LoginViewWeb extends StatelessWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late BuildContext _context;
  DataHolder conexion = DataHolder();

  TextEditingController usuarioControlador = TextEditingController();
  TextEditingController usuarioPassword = TextEditingController();

  void onClickRegistrar() {
    Navigator.of(_context).pushNamed("/registerview");
  }

  void onClickAceptar() async {
    if (usuarioControlador.text.isEmpty || usuarioPassword.text.isEmpty) {
      CustomDialog.show(_context, "Existen algún campo vacío, por favor, compruébalo");
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usuarioControlador.text,
        password: usuarioPassword.text,
      );

      if (await conexion.fbadmin.existenDatos()) {
        Navigator.of(_context).popAndPushNamed("/homeview");
      } else {
        Navigator.of(_context).popAndPushNamed("/perfilview");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CustomDialog.show(_context, "El usuario no existe");
      } else if (e.code == 'wrong-password') {
        CustomDialog.show(_context, "Contraseña incorrecta");
      } else {
        CustomDialog.show(_context, "Usuario o contraseña incorrectos");
      }
    }
  }

  Future<void> signInWithGoogle() async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (await conexion.fbadmin.existenDatos()) {
        Navigator.of(_context).popAndPushNamed("/homeview");
      } else {
        Navigator.of(_context).popAndPushNamed("/perfilview");
      }
      return;
    }

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (await conexion.fbadmin.existenDatos()) {
        Navigator.of(_context).popAndPushNamed("/homeview");
      } else {
        Navigator.of(_context).popAndPushNamed("/perfilview");
      }
    } on FirebaseAuthException catch (e) {
      CustomDialog.show(_context, "Error de autenticación con Google");
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            minHeight: 500,
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tfg BoardGames", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: customTextField(
                      tecUsername: usuarioControlador,
                      oscuro: false,
                      sHint: "Introduzca su Nombre",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: customTextField(
                      tecUsername: usuarioPassword,
                      oscuro: true,
                      sHint: "Introduzca su Contraseña",
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(onPressed: onClickAceptar, texto: 'Aceptar'),
                      CustomButton(onPressed: onClickRegistrar, texto: 'Registrar'),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}