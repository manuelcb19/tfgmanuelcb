import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/CustomViews/CustomDrawer.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbBoardGame.dart';
import 'package:tfgmanuelcb/FirebaseObjects/FbUsuario.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
import 'package:tfgmanuelcb/onBoarding/LoginView.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import '../CustomViews/CustomMenuBar.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DataHolder conexion = DataHolder();
  late List<DragAndDropList> ListaJuegosdrag;
  FbUsuario perfil = FbUsuario(nombre: "nombre", apellidos: "apellidos", id: "id", shint: "shint");
  late Future<void> _loadingFuture;
  bool mostrarBorrar = false;
  bool mostrarDesplazar = false;

  @override
  void initState() {
    super.initState();
    conseguirUsuario();
    ListaJuegosdrag = [];
    _initData();
    cargarDatosDesdeCache();
    _loadingFuture = _simulateLoading();
  }

  Future<void> _simulateLoading() async {

    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> conseguirUsuario() async {
    //FbUsuario perfil = await conexion.fbadmin.conseguirUsuario();
    print("FFFFFFFFFFFFFFFFFFFFFFFF"+perfil.nombre + perfil.shint + perfil.id + perfil.apellidos);
    setState(() async {
      FbUsuario perfil = await conexion.fbadmin.conseguirUsuario();
      print("ffffffffffffffffffffffffff"+perfil.nombre + perfil.shint + perfil.id + perfil.apellidos);
      this.perfil = perfil;
    });
    print("ffffffffffffffffffffffffff"+perfil.nombre + perfil.shint + perfil.id + perfil.apellidos);
  }

  Future<void> cargarDatosDesdeCache() async {
    List<FbBoardGame> cachedGames = await conexion.loadAllFbJuegos();
    print(perfil.shint.toString());
    if (cachedGames.isNotEmpty) {
      print("Juegos en el caché:");
      for (var juego in cachedGames) {
        print("${juego.id}: ${juego.nombre}");
      }
    }
  }

  Future<void> _initData() async {
    List<FbBoardGame> downloadedGamesCache = await conexion.loadAllFbJuegos();
    List<FbBoardGame> dowloadByFirebase = await conexion.fbadmin.descargarJuegos();
    List<FbBoardGame> downloadedGames;

    if(downloadedGamesCache.length == dowloadByFirebase.length) {
      downloadedGames = await conexion.loadAllFbJuegos();
    } else {
      downloadedGames = await conexion.fbadmin.descargarJuegos();
    }

    int compararPorOrden(FbBoardGame a, FbBoardGame b) {
      int ordenA = a.orden ?? 0;
      int ordenB = b.orden ?? 0;
      return ordenA.compareTo(ordenB);
    }

    downloadedGames.sort(compararPorOrden);

    List<DragAndDropList> lists = [
      DragAndDropList(
        children: downloadedGames.map((juego) {
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
                    trailing: mostrarBorrar
                        ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _borrarJuego(juego);
                      },
                    )
                        : null,
                    onTap: () {
                      conexion.juego = juego;
                      Navigator.pushNamed(context, '/detallesjuegoscreen', arguments: {});
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ];

    conexion.saveAllJuegosInCache(downloadedGames);

    setState(() {
      ListaJuegosdrag = lists;
    });
  }

  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = ListaJuegosdrag[oldListIndex].children.removeAt(oldItemIndex);

      ListaJuegosdrag[oldListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = ListaJuegosdrag.removeAt(oldListIndex);
      ListaJuegosdrag.insert(newListIndex, movedList);
    });
  }

  void fHomeViewMenuBar(int indice) {
    setState(() {
      if (indice == 1) {
        mostrarBorrar = false;
        if(mostrarDesplazar)
        {
          mostrarDesplazar = false;
        }
        else
        {
          mostrarDesplazar = true;
        }
      } else if (indice == 2) {
        if(mostrarBorrar)
          {
            mostrarBorrar = false;
          }
        else
          {
            mostrarBorrar = true;
          }
        mostrarDesplazar = false;
      }
    });
    _initData();
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
        '/moment',
        arguments: {},
      );

    } else if (indice == 2) {
      Navigator.of(context).pushNamed('/consultarjuegomesa', arguments: {},);
    }
       else if (indice == 3) {
         Navigator.of(context).pushNamed('/mapaview', arguments: {},);
      }
    else if (indice == 4) {
      Navigator.of(context).pushNamed('/editdatos', arguments: {},);
    }
  }
  void _borrarJuego(FbBoardGame juego) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar juego'),
          content: Text('¿Estás seguro de que quieres borrar este juego?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  conexion.fbadmin.eliminarJuego(juego.id.toString());
                  _initData();
                });
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _agregarJuegoDialog() async {
    String? selectedIdFromList = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String nombreJuegoBuscado = '';

        return AlertDialog(
          title: Text('Buscar y Seleccionar Juego'),
          content: SingleChildScrollView(
            child: Column(
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
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Map<int, String> diccionario =
                await conexion.httpAdmin.obtenerDiccionarioDeIds(nombreJuegoBuscado);

                String? selectedIdFromList = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Lista de IDs'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int id in diccionario.keys)
                              ListTile(
                                title: Text(diccionario[id]!),
                                onTap: () async {
                                  await conexion.fbadmin.agregarJuegoDeMesaAlUsuario(
                                      id.toString(), diccionario[id]!);
                                  Navigator.of(context).pop(id.toString());
                                  conexion.fbadmin.descargarJuegos();
                                  _initData();
                                },
                              ),
                          ],
                        ),
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
                } else {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Juegos'),
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actions: [ // Agregado para incluir CustomMenuBar en la AppBar
          CustomMenuBar(
            onItemTap: fHomeViewMenuBar,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return DragAndDropLists(
              children: ListaJuegosdrag,
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              listPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemDivider: Divider(
                thickness: 2,
                height: 2,
                color: Theme.of(context).colorScheme.background,
              ),
              itemDragHandle: mostrarDesplazar
                  ? DragHandle(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.menu,
                    color: Colors.blueGrey,
                  ),
                ),
              )
                  : null, // Eliminé la coma aquí
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarJuegoDialog,
        child: Icon(Icons.add),
      ),
      drawer: CustomDrawer(
        onItemTap: fHomeViewDrawerOnTap,
        imagen: perfil.shint,
      ),
    );
  }
}

