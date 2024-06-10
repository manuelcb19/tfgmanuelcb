

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../CustomViews/CustomDialog.dart';
import '../CustomViews/CustomTextField.dart';


class RegisterView extends StatelessWidget {
  late BuildContext _context;

  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordMyController = TextEditingController();
  TextEditingController passwordconfirmationMyController = TextEditingController();

  void onClickCancelar() {
    Navigator.of(_context).pop(); // Esto cierra la pantalla actual y vuelve a la anterior
  }

  void onClickAceptar() async {
    if (usuarioController.text.isEmpty || passwordMyController.text.isEmpty || passwordconfirmationMyController.text.isEmpty) {
      CustomDialog.show(_context, "Algun campo de los existente se encuentra vacio, por favor, rellenalo");
      return;
    }

    if (passwordMyController.text == passwordconfirmationMyController.text) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usuarioController.text,
          password: passwordMyController.text,
        );

        Navigator.pop(_context); // Esto cierra la pantalla actual y vuelve a la pantalla anterior
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          CustomDialog.show(_context, "Contraseña menor a 6 caracteres");
        } else if (e.code == 'email-already-in-use') {
          CustomDialog.show(_context, "El email ya existe");
        }
      } catch (e) {
        print(e);
      }
    } else {
      CustomDialog.show(_context, "Las contraseñas no son iguales");
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 300,
            minHeight: 500,
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Registrar Usuario", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: customTextField(
                      tecUsername: usuarioController,
                      oscuro: false,
                      sHint: "Introduzca su usuario",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: customTextField(
                      tecUsername: passwordMyController,
                      oscuro: true,
                      sHint: "Introduzca su contraseña",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: customTextField(
                      tecUsername: passwordconfirmationMyController,
                      oscuro: true,
                      sHint: "Introduzca la contraseña de nuevo",
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: onClickAceptar,
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Aceptar", style: TextStyle(fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: onClickCancelar,
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Cancelar", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}