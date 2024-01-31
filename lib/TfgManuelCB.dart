
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'onBoarding/LoginView.dart';



class TfgManuelCB extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    MaterialApp materialApp;
    materialApp=MaterialApp(title: "TfgManuel",
      routes: {
        '/loginview':(context) => LoginView(),
      },
      initialRoute: '/loginview',
    );
    return materialApp;
  }

}