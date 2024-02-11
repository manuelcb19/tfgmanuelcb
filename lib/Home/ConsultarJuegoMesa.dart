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
                String? nombreJuego = await _mostrarDialogoBusqueda();

                if (nombreJuego != null && nombreJuego.isNotEmpty) {
                  print("Nombre del juego seleccionado: $nombreJuego");
                  // Lógica para obtener la lista de IDs usando tu función
                  Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuego);

                  // Muestra una lista de nombres y permite al usuario seleccionar uno
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
                                  // Actualizar la interfaz de usuario con la información del juego
                                  setState(() {});
                                  // No cerramos el AlertDialog para que podamos ver la información en la pantalla principal
                                  // Navigator.of(context).pop(id.toString());
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

                  // Resto del código...
                  if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
                    print("ID seleccionada: $selectedIdFromList");
                    print('ID: ${boardGame!.name}' + "casaaaaaaaaaa");
                    // Navigator.of(context).pop(selectedIdFromList);
                  } else {
                    // Mostrar mensaje o realizar otras acciones si es necesario
                  }
                }
              },
              child: Text('Buscar Juego de Mesa'),
            ),
            if (boardGame != null)
            // Mostrar la información del juego si está disponible
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${boardGame!.id}'),
                  Text('Nombre: ${boardGame!.name}'),
                  Text('Descripción: ${boardGame!.description}'),
                  Text('Año de Publicación: ${boardGame!.yearPublished}'),
                  // Agrega más campos según sea necesario
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _mostrarDialogoBusqueda() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String nombreJuegoBuscado = ''; // Variable para almacenar el nombre del juego a buscar

        return AlertDialog(
          title: Text('Buscar y Seleccionar Juego'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  nombreJuegoBuscado = value; // Actualizar el nombre del juego a buscar
                },
                decoration: InputDecoration(
                  hintText: 'Ingrese el nombre del juego',
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nombreJuegoBuscado);
              },
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
