
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

  Future<int> obtenerOrdenMasAlto(String userId) async {
    QuerySnapshot snapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .orderBy("orden", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Asumiendo que el campo "orden" es de tipo int.
      return snapshot.docs.first.get("orden");
    } else {
      return 0;
    }
  }
  Future<Map<String, dynamic>> obtenerEstadisticasGlobales() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference juegosRef = db.collection("ColeccionJuegos").doc(userId).collection("juegos");

    QuerySnapshot juegosSnapshot = await juegosRef.get();
    List<QueryDocumentSnapshot> juegosDocs = juegosSnapshot.docs;

    if (juegosDocs.isEmpty) {
      return {'error': 'No hay datos disponibles'};
    }

    Map<String, dynamic> estadisticas = {
      'juegoConMasPartidas': '',
      'maxPartidas': 0,
      'juegoConMasPuntos': '',
      'maxPuntos': 0,
      'juegoConMasVictorias': '',
      'maxVictorias': 0,
      'juegoConMenosPartidas': '',
      'minPartidas': double.maxFinite.toInt(),
      'juegoConMenosPuntos': '',
      'minPuntos': double.maxFinite.toInt(),
    };

    List<Future<Map<String, dynamic>>> futures = juegosDocs.map((juegoDoc) async {
      String juegoNombre = juegoDoc['nombre'];
      var estadisticasJuego = await _calcularEstadisticasJuego(juegosRef, juegoDoc.id);
      return {
        'juegoNombre': juegoNombre,
        'estadisticasJuego': estadisticasJuego,
      };
    }).toList();

    List<Map<String, dynamic>> resultados = await Future.wait(futures);

    for (var resultado in resultados) {
      String juegoNombre = resultado['juegoNombre'];
      var estadisticasJuego = resultado['estadisticasJuego'];

      if (estadisticasJuego['numPartidas'] > estadisticas['maxPartidas']) {
        estadisticas['maxPartidas'] = estadisticasJuego['numPartidas'];
        estadisticas['juegoConMasPartidas'] = juegoNombre;
      }

      if (estadisticasJuego['totalPuntos'] > estadisticas['maxPuntos']) {
        estadisticas['maxPuntos'] = estadisticasJuego['totalPuntos'];
        estadisticas['juegoConMasPuntos'] = juegoNombre;
      }

      if (estadisticasJuego['totalVictorias'] > estadisticas['maxVictorias']) {
        estadisticas['maxVictorias'] = estadisticasJuego['totalVictorias'];
        estadisticas['juegoConMasVictorias'] = juegoNombre;
      }

      if (estadisticasJuego['numPartidas'] < estadisticas['minPartidas']) {
        estadisticas['minPartidas'] = estadisticasJuego['numPartidas'];
        estadisticas['juegoConMenosPartidas'] = juegoNombre;
      }

      if (estadisticasJuego['totalPuntos'] < estadisticas['minPuntos']) {
        estadisticas['minPuntos'] = estadisticasJuego['totalPuntos'];
        estadisticas['juegoConMenosPuntos'] = juegoNombre;
      }
    }

    return estadisticas;
  }

  Future<List<FbBoardGame>> buscarJuegosDeUsuario(String userId) async {
    List<FbBoardGame> juegos = [];
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

  Future<Map<String, dynamic>> _calcularEstadisticasJuego(CollectionReference juegosRef, String juegoId) async {
    CollectionReference partidasRef = juegosRef.doc(juegoId).collection("partidas");

    QuerySnapshot partidasSnapshot = await partidasRef.get();
    int numPartidas = partidasSnapshot.size;
    int totalPuntos = 0;
    int totalVictorias = 0;

    for (var partidaDoc in partidasSnapshot.docs) {
      var data = partidaDoc.data() as Map<String, dynamic>;
      totalPuntos += (data['puntos'] as num?)?.toInt() ?? 0;
      totalVictorias += (data['victorias'] as num?)?.toInt() ?? 0;
    }

    return {
      'numPartidas': numPartidas,
      'totalPuntos': totalPuntos,
      'totalVictorias': totalVictorias,
    };
  }
  Future<void> agregarJuegosDeMesaAlUsuarioLista(List<BoardGame> lista) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      for (var boardGame in lista) {
        await db.collection("ColeccionJuegos")
            .doc(userId)
            .collection("juegos")
            .doc(boardGame.id.toString()) // Asegúrate de que `id` sea una cadena
            .set({
          "nombre": boardGame.name, // Asumiendo que `BoardGame` tiene una propiedad `name`
          "yearPublished": boardGame.yearPublished,
          "image": boardGame.image.toString(),
          "id": boardGame.id

        });
      }
    } catch (e) {
      print("Error al agregar juegos de mesa al usuario: $e");
    }
  }

  Future<void> actualizarOrdenJuegos(Map<String, int> juegosOrdenados) async {
    List<FbBoardGame> juegosFirebase = await descargarJuegos();

    String userId = FirebaseAuth.instance.currentUser!.uid;

    for (var entry in juegosOrdenados.entries) {
      String nombreJuego = entry.key;
      int ordenJuego = entry.value;

      String nombreJuegoLimpio = nombreJuego;

      if (nombreJuego.startsWith('Text(') && nombreJuego.endsWith(')')) {
        nombreJuegoLimpio = nombreJuego.substring(5, nombreJuego.length - 1);
      }


      nombreJuegoLimpio = nombreJuegoLimpio.replaceAll('"', '');
      print("Nombre del juego limpio: $nombreJuegoLimpio, orden del juego: $ordenJuego");


      for (var juego in juegosFirebase) {
        print("Nombre del juego en Firebase: ${juego.nombre}");

        if (juego.nombre == nombreJuegoLimpio) {
          try {
            await db.collection("ColeccionJuegos")
                .doc(userId)
                .collection("juegos")
                .doc(juego.id.toString())
                .update({
              "orden": ordenJuego,
            });
            print('Orden actualizado para el juego: ${juego.nombre}, ID: ${juego.id}');
          } catch (e) {
            print('Error al actualizar el orden del juego: ${juego.nombre}, ID: ${juego.id}, Error: $e');
          }
        }
      }
    }
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

  Future<void> agregarJuegoDeMesaAlUsuario(String idJuego, String nombre) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      int numero = await obtenerOrdenMasAlto(userId);
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
        "id": boardGame?.id,
        "orden": numero,
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

  Future<void> eliminarPartida(FbBoardGame? juego, int orden) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot querySnapshot = await db
          .collection("ColeccionJuegos")
          .doc(userId)
          .collection("juegos")
          .doc(juego?.id.toString())
          .collection("partidas")
          .where("orden", isEqualTo: orden)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        print("Partida con orden $orden eliminada con éxito");
      } else {
        print("No se encontró la partida con el orden dado para eliminar");
      }
    } catch (e) {
      print("Error al eliminar la partida: $e");
    }
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