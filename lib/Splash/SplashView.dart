import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../FirebaseObjects/FbUsuario.dart';
import '../Singletone/DataHolder.dart';


class SplashView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashViewState();
  }
}

class _SplashViewState extends State<SplashView>{

  FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSession();
  }

  void checkSession() async {
    await Future.delayed(Duration(seconds: 3));

    if (FirebaseAuth.instance.currentUser != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference<FbUsuario> enlace = db.collection("Perfil").doc(uid).withConverter<FbUsuario>(
        fromFirestore: (snapshot, options) => FbUsuario.fromFirestore(snapshot),
        toFirestore: (usuario, options) => usuario.toFirestore(),
      );

      DocumentSnapshot<FbUsuario> docSnap = await enlace.get();

      if (docSnap.exists) {
        FbUsuario usuario = docSnap.data()!;

        if (usuario != null) {
          Navigator.pushReplacementNamed(context, "/homeview");
        } else {
          Navigator.pushReplacementNamed(context, "/perfilview");
        }
      } else {
        // El documento no existe, maneja el caso según tu lógica.
        Navigator.pushReplacementNamed(context, "/perfilview");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/loginview");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: DataHolder().platformAdmin.getScreenWidth() * 0.1,
          top: DataHolder().platformAdmin.getScreenHeight() * 0.1,
          width: DataHolder().platformAdmin.getScreenWidth() * 0.8,
          height: DataHolder().platformAdmin.getScreenHeight() * 0.8,
          child: Image.asset("resources/imagenInicial.png"),
        ),
        Positioned(
          left: DataHolder().platformAdmin.getScreenWidth() * 0.25,
          top: DataHolder().platformAdmin.getScreenHeight() * 0.6,
          width: DataHolder().platformAdmin.getScreenWidth() * 0.5,
          height: DataHolder().platformAdmin.getScreenHeight() * 0.2,
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}