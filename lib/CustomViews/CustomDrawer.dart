import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class CustomDrawer extends StatelessWidget {
  Function(int indice)? onItemTap;
  String imagen;

  CustomDrawer({Key? key, required this.onItemTap, required this.imagen}) : super(key: key);

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
                CircleAvatar(
                  radius: 50, // Ajusta el tamaño de la imagen
                  backgroundImage: NetworkImage(imagen),
                ),
                SizedBox(height: 10), // Espacio entre la imagen y el texto
                Text(
                  "Bienvenido",
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
          ListTile(
            title: const Text('Editar Perfil'),
            onTap: () {
              onItemTap!(4);
            },
          ),
        ],
      ),
    );
  }
}
