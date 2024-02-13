import 'package:bgg_api/bgg_api.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class ConsultarJuegoMesa extends StatefulWidget {
  @override
  _ConsultarJuegoMesaState createState() => _ConsultarJuegoMesaState();
}

class _ConsultarJuegoMesaState extends State<ConsultarJuegoMesa> {
  TextEditingController _searchController = TextEditingController();
  DataHolder conexion = DataHolder();
  BoardGame? boardGame; // Variable para almacenar la información del juego buscado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar Juego de Mesa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                String? nombreJuego = await conexion.dialogclass.showSearchDialog(context);
                if (nombreJuego != null && nombreJuego.isNotEmpty) {
                  print("Nombre del juego seleccionado: $nombreJuego");
                  Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuego);

                  String? selectedIdFromList = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Lista de IDs'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int id in diccionario.keys)
                              ListTile(
                                title: Text(diccionario[id]!),
                                onTap: () async {
                                  boardGame = await conexion.fbadmin.buscarJuegoMesa(id.toString(), diccionario[id]!);
                                  setState(() {});
                                },
                              ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Buscar Juego de Mesa'),
            ),
            if (boardGame != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${boardGame!.id}'),
                  Text('Nombre: ${boardGame!.name}'),
                  Text('Descripción: ${boardGame!.description}'),
                  Text('Año de Publicación: ${boardGame!.yearPublished}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
