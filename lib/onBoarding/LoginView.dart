

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../CustomViews/CustomButton.dart';
import '../CustomViews/CustomDialog.dart';
import '../CustomViews/CustomTextField.dart';
import '../Singletone/DataHolder.dart';


class LoginView extends StatelessWidget {

  FirebaseFirestore db = FirebaseFirestore.instance;
  late BuildContext _context;
  DataHolder conexion = DataHolder();

  TextEditingController usuarioControlador = TextEditingController();
  TextEditingController usuarioPassword = TextEditingController();

  void onClickRegistrar(){
    Navigator.of(_context).pushNamed("/registerview");
  }

  void onClickAceptar() async {

    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usuarioControlador.text,
        password: usuarioPassword.text
    );
    if (usuarioControlador.text.isEmpty || usuarioPassword.text.isEmpty) {
      CustomDialog.show(_context, "Existen algún campo vacío, por favor, compruébalo");
    } else {
      try {

        if (await conexion.fbadmin.existenDatos()){
          Navigator.of(_context).popAndPushNamed("/homeview");

        }

        else{
          Navigator.of(_context).popAndPushNamed("/perfilview");
        }

      } on FirebaseAuthException catch (e) {

        CustomDialog.show(_context, "Usuario o contraseña incorrectos");

        if (e.code == 'user-not-found') {

          CustomDialog.show(_context, "El usuario no existe");

        } else if (e.code == 'wrong-password') {

          CustomDialog.show(_context, "contraseña incorrecta");

        }
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

      print(userCredential.user?.displayName);


      if (await conexion.fbadmin.existenDatos()) {
        Navigator.of(_context).popAndPushNamed("/homeview");
      } else {
        Navigator.of(_context).popAndPushNamed("/perfilview");
      }

    } on FirebaseAuthException catch (e) {

      print("Error de autenticación: ${e.message}");
      CustomDialog.show(_context, "Error de autenticación con Google");
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    // TODO: implement build

    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          centerTitle: true,
          shadowColor: Colors.white,
          backgroundColor: Colors.deepPurple,
        ),
        backgroundColor: Colors.white,
        body:
        Center(
          child: ConstrainedBox(constraints: BoxConstraints(
            minWidth: 500,
            minHeight: 700,
            maxWidth: 1000,
            maxHeight: 900,
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text("Tfg BoardGames", style: TextStyle(fontSize: 25)),

                Padding(padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    child:  customTextField(tecUsername: usuarioControlador, oscuro: false, sHint: "introduzca su Nombre",)
                ),

                Padding(padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    child:  customTextField(tecUsername: usuarioPassword, oscuro: true, sHint: "introduzca su Contraseña",)
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(onPressed: onClickAceptar, texto: 'aceptar',),
                        CustomButton(onPressed: onClickRegistrar, texto: 'registrar',),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Color del texto (blanco)
                      ),
                      child: Text('Acceder con Google'),
                    ),
                  ],
                ),

              ],
            ),),
        )
    );
  }
}