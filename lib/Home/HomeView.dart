import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/CustomViews/CustomDrawer.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
import 'package:tfgmanuelcb/onBoarding/LoginView.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List<FbBoardGame> juegos = [];
  DataHolder conexion = DataHolder();
  late List<DragAndDropList> _contents;

  @override
  void initState() {
    super.initState();
    _contents = [];
    descargarJuegos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Juegos'),
      ),
      body: DragAndDropLists(
        children: _contents,
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        listPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemDivider: Divider(
          thickness: 2,
          height: 2,
          color: Theme.of(context).backgroundColor,
        ),
        itemDragHandle: DragHandle(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.menu,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarJuegoDialog,
        child: Icon(Icons.add),
      ),
      drawer: CustomDrawer(
        onItemTap: fHomeViewDrawerOnTap,
        imagen: "hhhh",
      ),
    );
  }

  void descargarJuegos() async {
    juegos.clear();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String userId = uid;

    QuerySnapshot<Map<String, dynamic>> juegosSnapshot = await db
        .collection("ColeccionJuegos")
        .doc(userId)
        .collection("juegos")
        .get();

    juegosSnapshot.docs.forEach((juegoDoc) {
      FbBoardGame juego = FbBoardGame.fromFirestore(juegoDoc, null);
      juegos.add(juego);
    });
    setState(() {
      _contents = [
        DragAndDropList(
          children: juegos.map((juego) {
            return DragAndDropItem(
              child: Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: juego.sUrlImg != null
                          ? Image.network(
                        juego.sUrlImg,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Container(),
                      title: Text(juego.nombre),
                      subtitle: Text('Año de Publicación: ${juego.yearPublished}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallesJuegoScreen(juego: juego),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ];
    });
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      // Tomar el elemento movido
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);

      // Insertarlo en la nueva posición
      _contents[oldListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }

  void fHomeViewDrawerOnTap(int indice) async {
    print("---->>>> " + indice.toString());

    if (indice == 0) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginView()),
        ModalRoute.withName('/loginview'),
      );
    } else if (indice == 1) {
      Navigator.of(context).pushNamed(
        '/editarperfil',
        arguments: {},
      );

    } else if (indice == 2) {
      Navigator.of(context).pushNamed(
        '/consultarjuegomesa',
        arguments: {},
      );
    }
  }

  Future<void> _agregarJuegoDialog() async {
    String? selectedIdFromList = await showDialog<String>(context: context, builder: (BuildContext context) {
        String nombreJuegoBuscado = '';

        return AlertDialog(
          title: Text('Buscar y Seleccionar Juego'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: nombreJuegoBuscado),
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
              onPressed: () async {
                Map<int, String> diccionario = await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuegoBuscado);

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
                                await conexion.fbadmin.agregarJuegoDeMesaAlUsuario(id.toString(), diccionario[id]!);
                                Navigator.of(context).pop(id.toString());
                                descargarJuegos();
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

                if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
                  print("ID seleccionada: $selectedIdFromList");
                  Navigator.of(context).pop(selectedIdFromList);
                } else {

                }
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (selectedIdFromList != null && selectedIdFromList.isNotEmpty) {
      print("ID seleccionada: $selectedIdFromList");
    }
  }
}