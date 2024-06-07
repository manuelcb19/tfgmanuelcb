
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';

import '../CustomViews/CustomTextField.dart';


class DetallesJuegoScreen extends StatefulWidget {
  final DataHolder conexion = DataHolder();

  @override
  _DetallesJuegoScreenState createState() => _DetallesJuegoScreenState();
}

class _DetallesJuegoScreenState extends State<DetallesJuegoScreen> {
  final DataHolder conexion = DataHolder();
  List<Map<String, dynamic>> partidasList = [];
  late FbBoardGame? juego;
  final TextEditingController tecNombre = TextEditingController();
  final TextEditingController tecPuntuacion = TextEditingController();

  @override
  void initState() {
    super.initState();
    juego = conexion.juego;
    descargarPartidas();
  }

  void descargarPartidas() async {
    partidasList.clear();
    partidasList = await conexion.fbadmin.descargarPartidas(juego);
    setState(() {});
  }

  void _showDetailsDialog(int orden, VoidCallback callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar Jugador y Puntuación'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: tecNombre,
                hintText: "Nombre del jugador",
                icon: Icons.person,
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: tecPuntuacion,
                hintText: "Nueva puntuación",
                icon: Icons.score,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
              ),
              onPressed: () {
                String nuevoNombre = tecNombre.text;
                int nuevaPuntuacion = int.parse(tecPuntuacion.text);
                conexion.fbadmin.modificarPartida(juego, orden, nuevoNombre, nuevaPuntuacion);
                Future.delayed(Duration(seconds: 2), () {
                  descargarPartidas();
                  Navigator.of(context).pop();
                  callback();
                });
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus partidas'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/estadisticas');
            },
          ),
        ],
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (juego?.sUrlImg != null)
            Image.network(
              juego!.sUrlImg!,
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              juego?.nombre ?? 'Nombre del Juego',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: partidasList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> partida = partidasList[index];
                Map<String, dynamic> partidas = partida['partidas'];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Partida ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8), // Espacio entre el título de la partida y los detalles de los jugadores
                        ...partidas.entries.map((e) {
                          return Text('- ${e.key}: ${e.value}');
                        }).toList(),
                      ],
                    ),
                    onTap: () {
                      _showDetailsDialog(partidasList[index]['orden'], descargarPartidas);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/partidasscreen', arguments: {}).then((_) {
            Future.delayed(Duration(seconds: 2), () {
              descargarPartidas();
            });
          });
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}