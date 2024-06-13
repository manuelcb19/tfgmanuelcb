import 'package:flutter/material.dart';

import '../FirebaseObjects/FbBoardGame.dart';
import '../Singletone/FirebaseAdmin.dart';

class BuscarJuegosUsuarioScreen extends StatefulWidget {
  @override
  _BuscarJuegosUsuarioScreenState createState() =>
      _BuscarJuegosUsuarioScreenState();
}

class _BuscarJuegosUsuarioScreenState
    extends State<BuscarJuegosUsuarioScreen> {
  FirebaseAdmin firebaseAdmin = FirebaseAdmin();
  TextEditingController idController = TextEditingController();
  List<FbBoardGame> juegos = [];
  bool isLoading = false;
  bool userNotFound = false;
  String? selectedId; // Cambia el tipo de la variable selectedId

  Future<void> buscarJuegos() async {
    setState(() {
      isLoading = true;
      userNotFound = false;
    });

    try {
      List<FbBoardGame> resultado =
      await firebaseAdmin.buscarJuegosDeUsuario(selectedId!);
      setState(() {
        juegos = resultado;
        isLoading = false;
        userNotFound = resultado.isEmpty;
      });
    } catch (e) {
      print('Error al buscar juegos: $e');
      setState(() {
        isLoading = false;
        userNotFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Buscar Juegos de Usuario(Futura implementacion)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Selecciona el ID del usuario para buscar sus juegos de mesa:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedId,
              onChanged: (value) {
                setState(() {
                  selectedId = value!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: "0UMNY7ah04fiDle421Bn15LzsXN2",
                  child: Text("0UMNY7ah04fiDle421Bn15LzsXN2"),
                ),
                DropdownMenuItem(
                  value: "9OITEl8nPHUAZhMTQmXS393Und03",
                  child: Text("9OITEl8nPHUAZhMTQmXS393Und03"),
                ),
                DropdownMenuItem(
                  value: "dvIFCcdtAcNHDm7mvYZGEUBzfpn2",
                  child: Text("dvIFCcdtAcNHDm7mvYZGEUBzfpn2"),
                ),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: buscarJuegos,
              child: Text('Buscar'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : userNotFound
                ? Text(
              'No se encontraron juegos para el usuario ingresado.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            )
                : Expanded(
              child: ListView.builder(
                itemCount: juegos.length,
                itemBuilder: (context, index) {
                  FbBoardGame juego = juegos[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        juego.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('ID: ${juego.id}'),
                      leading: juego.sUrlImg != null
                          ? Image.network(
                        juego.sUrlImg,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.image_not_supported,
                          size: 50),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}