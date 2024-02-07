import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/Singletone/HttpAdmin.dart';

import 'FirebaseAdmin.dart';


class DataHolder {

  static final DataHolder _dataHolder = DataHolder._internal();

  String sNombre="TfgManuelCB";
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAdmin fbadmin=FirebaseAdmin();
  HttpAdmin httpAdmin=HttpAdmin();
  DataHolder._internal() {
  }
  void initDataHolder(){


  }

  factory DataHolder(){
    return _dataHolder;
  }
}