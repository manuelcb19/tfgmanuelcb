import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function(int indice)? onBotonesClicked;
  final Function()? onPressed;
  final String texto;

  CustomButton({
    Key? key,
    this.onBotonesClicked,
    this.onPressed,
    required this.texto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onBotonesClicked != null)
          ...[
            TextButton(
              onPressed: onBotonesClicked != null ? () => onBotonesClicked!(0) : null,
              child: Icon(Icons.list, color: Colors.pink),
            ),
            TextButton(
              onPressed: onBotonesClicked != null ? () => onBotonesClicked!(1) : null,
              child: Icon(Icons.grid_view, color: Colors.pink),
            ),
          ],
        if (onPressed != null)
          TextButton(
            onPressed: () {
              onPressed!();
            },
            child: Text(texto),
          ),
      ],
    );
  }
}