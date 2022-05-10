import 'package:flutter/material.dart';

import '../main.dart';

// ignore: use_key_in_widget_constructors
class Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        alignment: Alignment.center,
        height: 420,
        margin: const EdgeInsets.only(top: 120),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/M2L net rond.png"),
              fit: BoxFit.cover),
        ),
        child: AlertDialog(
          content: const Text('Erreur connexion, veuillez réessayer!'),
          actions: <Widget>[
            ElevatedButton.icon(
              label: const Text('OK'),
              icon: const Icon(Icons.check),
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
