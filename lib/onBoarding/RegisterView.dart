

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../CustomViews/CustomDialog.dart';
import '../CustomViews/CustomTextField.dart';


class RegisterView extends StatelessWidget{

  late BuildContext _context;

  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordMyController = TextEditingController();
  TextEditingController passwordconfirmationMyController = TextEditingController();


  void onClickCancelar(){

    Navigator.of(_context).pushNamed("/loginview");

  }

  void onClickAceptar() async {


    switch(usuarioController.text.isEmpty || passwordMyController.text.isEmpty || passwordconfirmationMyController.text.isEmpty){

      case true:

        CustomDialog.show(_context, "Algun campo de los existente se encuentra vacio, por favor, rellenalo");
        break;

      case false:

        if(passwordMyController.text == passwordconfirmationMyController.text)
        {
          try {

            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: usuarioController.text,
              password: passwordMyController.text,
            );

            Navigator.of(_context).pushNamed("/loginview");
          }


          on FirebaseAuthException catch (e) {

            if (e.code == 'weak-password') {

              CustomDialog.show(_context, "contraseña menor a 6 caracteres");


            } else if (e.code == 'email-already-in-use') {

              CustomDialog.show(_context, "el email ya existe");


            }

            Navigator.of(_context).pushNamed("/homeview");
          }
          catch (e) {
            print(e);
          }
        }

        else
          {
            CustomDialog.show(_context, "Las contraseñas no son iguales");
          }

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    // TODO: implement build

    return Scaffold(
        appBar: AppBar(
          title: const Text('Registrarse'),
          centerTitle: true,
          shadowColor: Colors.black,
          backgroundColor: Colors.deepPurple,
        ),
        backgroundColor: Colors.white10,
        body:
        Center(
          child: ConstrainedBox(constraints: BoxConstraints(
            minWidth: 500,
            minHeight: 700,
            maxWidth: 1000,
            maxHeight: 900,
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
      Text("Registrar Usuario",style: TextStyle(fontSize: 25)),


      Padding(padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            child:  customTextField(tecUsername: usuarioController,oscuro: false,sHint: "introduzca su usuario",)
      ),

      Padding(padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            child:  customTextField( tecUsername: passwordMyController, oscuro: true,sHint: "introduzca su contraseña")
      ),

      Padding(padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            child:  customTextField( tecUsername: passwordconfirmationMyController, oscuro: true, sHint: "introduzca la contraseña de nuevo",)
      ),

      Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onClickAceptar, child: Text("Aceptar"),),
            TextButton( onPressed: onClickCancelar, child: Text("Cancelar"),)

          ],)

              ],
            ),),
        )
    );
  }

}