import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCellView extends StatelessWidget {
  final String imagen;
  final String sTexto;

  const CustomCellView({
    Key? key,
    required this.sTexto,
    required this.imagen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                sTexto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Image.network(
              imagen,
              height: 200.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}