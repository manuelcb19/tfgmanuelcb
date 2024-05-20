import 'package:flutter/material.dart';

class CustomMenuBar extends StatelessWidget {
  final Function(int indice)? onItemTap;

  CustomMenuBar({Key? key, required this.onItemTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (int result) {
        onItemTap!(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Modificar Orden'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Borrar'),
        ),
      ],
    );
  }
}