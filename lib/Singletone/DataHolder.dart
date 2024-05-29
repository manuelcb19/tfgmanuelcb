import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfgmanuelcb/Singletone/FirebaseAdmin.dart';
import 'package:tfgmanuelcb/Singletone/HttpAdmin.dart';
import 'package:tfgmanuelcb/Singletone/DialogClass.dart';
import 'package:tfgmanuelcb/Singletone/PlatformAdmin.dart';

import '../FirebaseObjects/FbBoardGame.dart';


class DataHolder {

  static final DataHolder _dataHolder = DataHolder._internal();

  FbBoardGame? coleccionJuego;
  late FbBoardGame juego;
  String sNombre="TfgManuelCB";
  FirebaseFirestore db = FirebaseFirestore.instance;
  DialogClass dialogclass = DialogClass();
  FirebaseAdmin fbadmin=FirebaseAdmin();
  HttpAdmin httpAdmin=HttpAdmin();
  late PlatformAdmin platformAdmin;
  DataHolder._internal() {
  }
  void initDataHolder(){


  }

  factory DataHolder(){
    return _dataHolder;
  }


  void saveAllJuegosInCache(List<FbBoardGame> juegos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    for (var juego in juegos) {
      prefs.setString('fbboardgame_nombre_${juego.id}', juego.nombre);
      prefs.setInt('fbboardgame_id_${juego.id}', juego.id);
      prefs.setInt('fbboardgame_orden_${juego.id}', juego.orden);
      prefs.setInt('fbboardgame_yearpublished_${juego.id}', juego.yearPublished);
      prefs.setString('fbboardgame_surlimg_${juego.id}', juego.sUrlImg);
    }
  }

  Future<List<FbBoardGame>> loadAllFbJuegos() async {
    List<FbBoardGame> juegos = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Recorre las claves del caché y agrega juegos a la lista
    prefs.getKeys().forEach((key) {
      if (key.startsWith('fbboardgame_nombre_')) {
        int id = int.parse(key.split('_').last);

        String? fbboardgame_nombre = prefs.getString('fbboardgame_nombre_$id');
        int? fbboardgame_orden = prefs.getInt('fbboardgame_orden_$id');
        int? fbboardgame_yearpublished = prefs.getInt('fbboardgame_yearpublished_$id');
        String? fbboardgame_surlimg = prefs.getString('fbboardgame_surlimg_$id');

        FbBoardGame juego = FbBoardGame(
          nombre: fbboardgame_nombre!,
          id: id,
          orden: fbboardgame_orden ?? 0,
          yearPublished: fbboardgame_yearpublished ?? 0,
          sUrlImg: fbboardgame_surlimg ?? "",
        );

        juegos.add(juego);
      }
    });

    return juegos;
  }

  Future<void> recargarCacheDeJuegos(List<FbBoardGame> juegos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtenemos las claves de la caché relacionadas con los juegos
    List<String> keysToDelete = prefs.getKeys().where((key) => key.startsWith('fbboardgame_')).toList();

    // Eliminamos las claves de forma asíncrona utilizando un bucle for
    for (var key in keysToDelete) {
      await prefs.remove(key);
    }

    // Agregamos los juegos actualizados a la caché
    for (var juego in juegos) {
      await prefs.setString('fbboardgame_nombre_${juego.id}', juego.nombre);
      await prefs.setInt('fbboardgame_orden_${juego.id}', juego.orden ?? 0);
      await prefs.setInt('fbboardgame_yearpublished_${juego.id}', juego.yearPublished ?? 0);
      await prefs.setString('fbboardgame_surlimg_${juego.id}', juego.sUrlImg ?? "");
    }
  }
  void initPlatformAdmin(BuildContext context){
    platformAdmin=PlatformAdmin(context: context);
  }
}




