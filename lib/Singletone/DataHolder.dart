import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfgmanuelcb/Singletone/FirebaseAdmin.dart';
import 'package:tfgmanuelcb/Singletone/HttpAdmin.dart';
import 'package:tfgmanuelcb/Singletone/DialogClass.dart';


class DataHolder {

  static final DataHolder _dataHolder = DataHolder._internal();

  String sNombre="TfgManuelCB";
  FirebaseFirestore db = FirebaseFirestore.instance;
  DialogClass dialogclass = DialogClass();
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