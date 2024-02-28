
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Home/ConsultarJuegoMesa.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Home/HomeView.dart';
import 'package:tfgmanuelcb/Home/Moment.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
import 'package:tfgmanuelcb/onBoarding/PerfilView.dart';
import 'package:tfgmanuelcb/onBoarding/RegisterView.dart';

import 'Splash/SplashView.dart';
import 'onBoarding/LoginView.dart';



class TfgManuelCB extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    DataHolder().initPlatformAdmin(context);
    MaterialApp materialApp;
    materialApp=MaterialApp(title: "TfgManuel",
      routes: {
        '/loginview':(context) => LoginView(),
        '/registerview':(context) => RegisterView(),
        '/perfilview':(context) => PerfilView(),
        '/homeview':(context) => HomeView(),
        '/detallesjuegoscreen':(context) => DetallesJuegoScreen(),
        '/consultarjuegomesa':(context) => ConsultarJuegoMesa(),
        '/splashview':(context) => SplashView(),
        '/moment':(context) => Moment(),
        '/partidasscreen':(context) => PartidasScreen(),
      },
      initialRoute: '/splashview',
    );
    return materialApp;
  }

}