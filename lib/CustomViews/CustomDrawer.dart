import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int indice)? onItemTap;
  final String imagen;

  CustomDrawer({Key? key, required this.onItemTap, required this.imagen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            accountName: Text(
              "Bienvenido",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(""),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(imagen),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.edit,
                  text: 'Editar Perfil',
                  onTap: () => onItemTap!(4),
                ),
                _buildDrawerItem(
                  icon: Icons.photo,
                  text: 'Memory',
                  onTap: () => onItemTap!(1),
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.gamepad,
                  text: 'Consultar Juego De Mesa',
                  onTap: () => onItemTap!(2),
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today,
                  text: 'Calendario',
                  onTap: () => onItemTap!(5),
                ),
                _buildDrawerItem(
                  icon: Icons.store,
                  text: 'Consultar Tienda mas Cercana',
                  onTap: () => onItemTap!(3),
                ),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  text: 'Cerrar Sesion',
                  onTap: () => onItemTap!(0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.blue : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}