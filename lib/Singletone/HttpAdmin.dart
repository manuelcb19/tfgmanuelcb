

import 'package:bgg_api/bgg_api.dart';

class HttpAdmin {
  HttpAdmin();

  Future<Map<int, String>> obtenerDiccionarioDeIds(String nombreJuego) async {
    try {
      var bgg = Bgg();
      var searchBoardGamesResult = await bgg.searchBoardGames(nombreJuego);

      if (searchBoardGamesResult != null && searchBoardGamesResult.isNotEmpty) {
        // Utilizamos un Map para almacenar el ID como clave y el nombre como valor
        Map<int, String> diccionarioIds = {};

        for (var boardGame in searchBoardGamesResult) {
          if (boardGame.id != null && boardGame.name != null) {
            diccionarioIds[boardGame.id!] = boardGame.name!;
            print(diccionarioIds[boardGame.id!] = boardGame.name!);
          }
        }

        return diccionarioIds;
      } else {
        return {};
      }
    } catch (e) {
      // Manejar errores aquí
      print("Error al obtener el diccionario de IDs: $e");
      return {};
    }
  }

  }

