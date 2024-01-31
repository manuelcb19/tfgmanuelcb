import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Singletone/DataHolder.dart';
import 'TfgManuelCB.dart';
import 'firebase_options.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DataHolder().initDataHolder();
  TfgManuelCB tfgmanuelcb= TfgManuelCB();
  runApp(tfgmanuelcb);


}
