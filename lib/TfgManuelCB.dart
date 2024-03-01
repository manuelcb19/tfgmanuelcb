
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfgmanuelcb/Home/ConsultarJuegoMesa.dart';
import 'package:tfgmanuelcb/Home/DetallesJuegoScreen.dart';
import 'package:tfgmanuelcb/Home/HomeView.dart';
import 'package:tfgmanuelcb/Home/Moment.dart';
import 'package:tfgmanuelcb/Home/PartidasScreen.dart';
import 'package:tfgmanuelcb/Singletone/DataHolder.dart';
import 'package:tfgmanuelcb/Splash/SplashViewWeb.dart';
import 'package:tfgmanuelcb/onBoarding/PerfilView.dart';
import 'package:tfgmanuelcb/onBoarding/RegisterView.dart';

import 'Splash/SplashView.dart';
import 'onBoarding/LoginView.dart';
import 'onBoarding/LoginViewWeb.dart';



class TfgManuelCB extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    DataHolder().initPlatformAdmin(context);
    MaterialApp materialApp;
    if (kIsWeb) {
      materialApp=MaterialApp(title: "TfgManuel",
        routes: {
          '/loginviewweb':(context) => LoginViewWeb(),
          '/registerview':(context) => RegisterView(),
          '/perfilview':(context) => PerfilView(),
          '/homeview':(context) => HomeView(),
          '/detallesjuegoscreen':(context) => DetallesJuegoScreen(),
          '/consultarjuegomesa':(context) => ConsultarJuegoMesa(),
          '/splashviewweb':(context) => SplashViewWeb(),
          '/moment':(context) => Moment(),
          '/partidasscreen':(context) => PartidasScreen(),
        },
        initialRoute: '/splashviewweb',
      );
    }
    else{
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
        debugShowCheckedModeBanner: false,
      );

    }
    return materialApp;
  }

}

