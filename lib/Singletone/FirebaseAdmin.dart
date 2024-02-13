
import 'package:bgg_api/bgg_api.dart';
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

  Future<void> agregarJuegoDeMesaAlUsuario(String idJuego, String nombre) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      var bgg = Bgg();
      var boardGame = await bgg.getBoardGame(int.parse(idJuego));
      await db.collection("ColeccionJuegos")
          .doc(userId)
          .collection("juegos")
          .doc(idJuego)
          .set({
          "nombre": nombre,
          "yearPublished": boardGame?.yearPublished,
          "image": boardGame?.image.toString(),
          "id": boardGame?.id
        });

    } catch (e) {
      print("Error al agregar juego de mesa al usuario: $e");
    }
  }

  Future<BoardGame?> buscarJuegoMesa(String idJuego, String nombre) async {
    BoardGame? boardGame;
    try {
      var bgg = Bgg();
      boardGame = await bgg.getBoardGame(int.parse(idJuego));

    } catch (e) {
      print("Error al agregar juego de mesa al usuario: $e");
    }

    return boardGame;
  }


  Future<void> anadirUsuario(String nombre, String apellidos, String img) async {
    String uidUsuario = FirebaseAuth.instance.currentUser!.uid;
    FbUsuario usuario = FbUsuario(nombre: nombre, apellidos: apellidos, id: uidUsuario, shint: img);
    await db.collection("Perfil").doc(uidUsuario).set(usuario.toFirestore());
  }



}