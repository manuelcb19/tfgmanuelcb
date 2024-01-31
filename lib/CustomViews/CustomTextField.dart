import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class customTextField extends StatelessWidget
{

  TextEditingController tecUsername = TextEditingController();
  String contenido;
  bool oscuro;
  String sHint;

  customTextField({Key? key, this.contenido="", required this.tecUsername, required this.oscuro, this.sHint="s"}) : super (key : key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Row row = Row(
      children: [
        Flexible(child : TextFormField(
          controller: tecUsername,
          obscureText: oscuro,
          decoration: InputDecoration(
              border:  OutlineInputBorder(),
              hintText: contenido,
              labelText: sHint
          ),
        )
        )
      ],
    );
    return row;
  }

}