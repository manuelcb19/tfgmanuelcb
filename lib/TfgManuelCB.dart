
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Home/ConsultarJuegoMesa.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Home/HomeView.dart';
import 'package:tfgmanuelcb/onBoarding/PerfilView.dart';
import 'package:tfgmanuelcb/onBoarding/RegisterView.dart';

import 'onBoarding/LoginView.dart';



class TfgManuelCB extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    MaterialApp materialApp;
    materialApp=MaterialApp(title: "TfgManuel",
      routes: {
        '/loginview':(context) => LoginView(),
        '/registerview':(context) => RegisterView(),
        '/perfilview':(context) => PerfilView(),
        '/homeview':(context) => HomeView(),
        '/detallesjuegoscreen':(context) => DetallesJuegoScreen(),
        '/consultarjuegomesa':(context) => ConsultarJuegoMesa(),


      },
      initialRoute: '/loginview',
    );
    return materialApp;
  }

}