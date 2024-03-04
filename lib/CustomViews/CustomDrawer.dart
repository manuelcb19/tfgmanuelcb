import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class CustomDrawer extends StatelessWidget {


  Function(int indice)? onItemTap;
  String imagen;

  CustomDrawer({Key? key, required this.onItemTap, required this.imagen
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imagen,
                  width: 100,
                  height: 100,
                ),
                Text(
                  "Bienvenido",
                  style: TextStyle(color: Colors.white,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            selectedColor: Colors.blue,
            selected: true,
            title: const Text('Memory'),
            onTap: () {
              onItemTap!(1);
            },
          ),
          ListTile(
            title: const Text('Cerrar Sesion'),
            onTap: () {
              onItemTap!(0);
            },
          ),
          ListTile(
            title: const Text('Consultar Juego De Mesa'),
            onTap: () {
              onItemTap!(2);
            },

          ),
          ListTile(
            title: const Text('Consultar Tienda mas Cercana'),
            onTap: () {
              onItemTap!(3);
            },

          ),
        ],
      ),
    );
  }
}
