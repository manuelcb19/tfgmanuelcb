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
    FbUsuario perfil = await conexion.fbadmin.conseguirUsuario();
    setState(() {
      this.perfil = perfil;
    });
  }

  Future<void> cargarDatosDesdeCache() async {
    List<FbBoardGame> cachedGames = await conexion.loadAllFbJuegos();
    if (cachedGames.isNotEmpty) {
      for (var juego in cachedGames) {
        print("${juego.id}: ${juego.nombre}");
      }
    }
  }

  Future<void> recargarCache() async {
    List<FbBoardGame> juegos = await conexion.fbadmin.descargarJuegos();
    await conexion.recargarCacheDeJuegos(juegos);
  }

  Future<void> _initData() async {
    List<FbBoardGame> downloadedGamesCache = await conexion.loadAllFbJuegos();
    List<FbBoardGame> dowloadByFirebase = await conexion.fbadmin.descargarJuegos();
    List<FbBoardGame> downloadedGames;
    recargarCache();
    if (downloadedGamesCache.length == dowloadByFirebase.length) {
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
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: juego.sUrlImg != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        juego.sUrlImg,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(),
                    title: Text(
                      juego.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Año de Publicación: ${juego.yearPublished}'),
                    trailing: mostrarBorrar
                        ? IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
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
    obtenerNombreYOrdenDeJuego();
    recargarCache();
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = ListaJuegosdrag.removeAt(oldListIndex);
      ListaJuegosdrag.insert(newListIndex, movedList);
    });
  }

  void obtenerNombreYOrdenDeJuego() {
    Map<String, int> juegosOrdenados = {};

    for (var i = 0; i < ListaJuegosdrag.length; i++) {
      var lista = ListaJuegosdrag[i];

      for (var j = 0; j < lista.children.length; j++) {
        var item = lista.children[j];
        Widget childWidget = item.child;

        if (childWidget is Card) {
          Card card = childWidget;
          ListTile? listTile;
          if (card.child is ListTile) {
            listTile = card.child as ListTile;
          } else if (card.child is Column) {
            Column column = card.child as Column;
            for (var widget in column.children) {
              if (widget is ListTile) {
                listTile = widget;
                break;
              }
            }
          }

          if (listTile != null) {
            String? nombreJuego;
            if (listTile.title is Text) {
              nombreJuego = (listTile.title as Text).data;
            }

            if (nombreJuego != null) {
              int ordenJuego = i * lista.children.length + j + 1;
              juegosOrdenados[nombreJuego] = ordenJuego;
            }
          }
        }
      }
    }

    conexion.fbadmin.actualizarOrdenJuegos(juegosOrdenados);
  }

  void fHomeViewMenuBar(int indice) {
    setState(() {
      if (indice == 1) {
        mostrarBorrar = false;
        mostrarDesplazar = !mostrarDesplazar;
      } else if (indice == 2) {
        mostrarBorrar = !mostrarBorrar;
        mostrarDesplazar = false;
      }
    });
    // Actualizar la lista para reflejar los cambios
    _initData();
  }

  void fHomeViewDrawerOnTap(int indice) async {
    if (indice == 0) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginView()),
        ModalRoute.withName('/loginview'),
      );
    } else if (indice == 1) {
      Navigator.of(context).pushNamed('/moment', arguments: {});
    } else if (indice == 2) {
      Navigator.of(context).pushNamed('/consultarjuegomesa', arguments: {});
    } else if (indice == 3) {
      Navigator.of(context).pushNamed('/mapaview', arguments: {});
    } else if (indice == 4) {
      Navigator.of(context).pushNamed('/editdatos', arguments: {});
    } else if (indice == 5) {
      Navigator.of(context).pushNamed('/calendarscreen', arguments: {});
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
        actions: [
          CustomMenuBar(
            onItemTap: fHomeViewMenuBar,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
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
                  : null,
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