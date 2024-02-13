


import 'package:flutter/material.dart';

class DialogClass
{
  Future<String?> showSearchDialog(BuildContext context) async {
    TextEditingController _searchController = TextEditingController();
    String nombreJuegoBuscado = '';

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar y Seleccionar Juego'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  nombreJuegoBuscado = value;
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