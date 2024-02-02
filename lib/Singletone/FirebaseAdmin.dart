
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbUsuario.dart';

class FirebaseAdmin {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool> existenDatos() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> datos = await
    db.collection("Perfil").doc(uid).get();

    if (datos.exists) {
      return true;
    }
    else {
      return false;
    }
  }


  Future<void> anadirUsuario(String nombre, String apellidos, String img) async {
    String uidUsuario = FirebaseAuth.instance.currentUser!.uid;
    FbUsuario usuario = FbUsuario(nombre: nombre, apellidos: apellidos, id: uidUsuario, shint: img);
    await db.collection("Perfil").doc(uidUsuario).set(usuario.toFirestore());
  }



}