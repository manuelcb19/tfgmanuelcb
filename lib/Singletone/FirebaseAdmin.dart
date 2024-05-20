
import 'package:bgg_api/bgg_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbImagen.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbUsuario.dart';

class FirebaseAdmin {
  FbUsuario? usuario;
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

  Future<BoardGame?> ConsultarJuego(String idJuego)
  async {
    var bgg = Bgg();
    var boardGame = await bgg.getBoardGame(int.parse(idJuego));

    return boardGame;
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

  Future<List<FbBoardGame>> descargarJuegos() async {
    List<FbBoardGame> juegos = [];
    FirebaseFirestore db = FirebaseFirestore.instance;

    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    QuerySnapshot<Map<String, dynamic>> juegosSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .get();

    juegosSnapshot.docs.forEach((juegoDoc) {
      FbBoardGame juego = FbBoardGame.fromFirestore(juegoDoc, null);
      juegos.add(juego);
    });

    return juegos;
  }

  Future<List<FbImagen>> descargarMemories(String userId) async {
    List<FbImagen> imagenes = [];
    try {
      QuerySnapshot<Map<String, dynamic>> memoriesSnapshot = await db
          .collection("memory")
          .doc(userId)
          .collection("memories")
          .get();

      imagenes = memoriesSnapshot.docs
          .map((doc) => FbImagen.fromFirestore(doc, null))
          .toList();
    } catch (e) {
      print("Error al descargar memorias: $e");
    }

    return imagenes;
  }

  Future<void> eliminarJuego2(String juegoId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juegoId).get();

    await FirebaseFirestore.instance
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juegoId)
        .collection("partidas")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  Future<void> eliminarJuego(String juegoId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juegoId)
        .delete();
    await FirebaseFirestore.instance
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juegoId)
        .collection("partidas")
        .get()
        .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
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

  void modificarPartida(FbBoardGame? juego, int ordenParametro, String nombre, int nuevaPuntuacion) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {

      QuerySnapshot querySnapshot = await db
          .collection("ColeccionJuegos")
          .doc(userId)
          .collection("juegos")
          .doc(juego?.id.toString())
          .collection("partidas")
          .where("orden", isEqualTo: ordenParametro)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference partidaRef = querySnapshot.docs.first.reference;

        DocumentSnapshot partidaSnapshot = await partidaRef.get();
        if (partidaSnapshot.exists) {

          Map<String, dynamic> partidasMap = (partidaSnapshot.data() as Map<String, dynamic>?)?["partidas"] ?? {};

          print("Datos actuales antes de la actualización: $partidasMap");

          if (partidasMap.containsKey(nombre)) {

            partidasMap[nombre] = nuevaPuntuacion;

            await partidaRef.update({"partidas": partidasMap});

            print("Puntuación actualizada con éxito");
            print("Datos actualizados: $partidasMap");
          } else {
            print("El nombre '$nombre' no existe en el mapa 'partidas'");
          }
        }
      } else {
        print("No se encontraron documentos con el parámetro 'orden' dado");
      }
    } catch (e) {
      print("Error al modificar la partida: $e");
    }
  }

  Future<List<Map<String, dynamic>>> descargarPartidas(FbBoardGame? juego) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List<Map<String, dynamic>> partidasList = [];
    String userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot<Map<String, dynamic>> partidasSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .doc(juego?.id.toString())
        .collection("partidas")
        .get();

    partidasList.clear();
    for (var doc in partidasSnapshot.docs) {
      Map<String, dynamic> partidaData = doc.data() as Map<String, dynamic>;
      partidasList.add(partidaData);
    }

    return partidasList;
  }



  Future<FbUsuario> conseguirUsuario() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    print(uid);

    DocumentReference<FbUsuario> enlace = db.collection("Perfil").doc(uid).withConverter(
      fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) => FbUsuario.fromFirestore(snapshot),
      toFirestore: (FbUsuario usuario, _) => usuario.toFirestore(),
    );

    FbUsuario usuario;

    DocumentSnapshot<FbUsuario> docSnap = await enlace.get();
    usuario = docSnap.data()!;

    return usuario;
  }

  Future<void> anadirUsuario(String nombre, String apellidos, String img) async {
    String uidUsuario = FirebaseAuth.instance.currentUser!.uid;
    FbUsuario usuario = FbUsuario(nombre: nombre, apellidos: apellidos, id: uidUsuario, shint: img);
    await db.collection("Perfil").doc(uidUsuario).set(usuario.toFirestore());
  }



}