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
  TextEditingController _searchController = TextEditingController();
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
        // Si necesitas un manejador de arrastre para las listas, puedes descomentar y ajustar el siguiente código:
        /*
        listDragHandle: DragHandle(
          verticalAlignment: DragHandleVerticalAlignment.top,
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.menu,
              color: Colors.black26,
            ),
          ),
        ),
        */
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
      _contents = juegos.map((juego) {
        return DragAndDropList(
          children: <DragAndDropItem>[
            DragAndDropItem(
              child: Card( // Usamos Card para un mejor estilo visual
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.image), // Sustituir por la imagen del juego si está disponible
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
            ),
          ],
        );
      }).toList();
    });
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      // Guardar los elementos que se van a intercambiar
      var movedItem1 = _contents[oldListIndex].children[oldItemIndex];
      var movedItem2 = _contents[newListIndex].children[newItemIndex];

      // Intercambiar los elementos
      _contents[oldListIndex].children[oldItemIndex] = movedItem2;
      _contents[newListIndex].children[newItemIndex] = movedItem1;
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
    String? selectedIdFromList = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
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
                  // Mostrar mensaje o realizar otras acciones si es necesario
                }
              },
              child: Text('Cancelar'),
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
