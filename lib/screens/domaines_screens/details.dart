//import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

import '../../env.dart';
import '../../main.dart';
import '../../models/domaine.dart';
import 'edit.dart';

@immutable
class DetailsDomaine extends StatefulWidget {
  final Domaine? domaine;
  final bool? visible;

  // ignore: use_key_in_widget_constructors
  const DetailsDomaine({this.domaine, this.visible});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<DetailsDomaine> {
  

  void deleteDomaine(context) async {
    await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/delete.php"),
      body: jsonEncode({
        "id": widget.domaine!.id,
      }),
    );
    // Navigator.pop(context) = .push(context);
    //refresh after an API delete
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/listDomaine', (Route<dynamic> route) => false);
  }

  void confirmDelete(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Vous êtes sûr de le supprimer?'),
          actions: <Widget>[
            ElevatedButton.icon(
              label: const Text('Non'),
              icon: const Icon(Icons.cancel),
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Oui"),
              onPressed: () => deleteDomaine(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Détailles du domaine'),
        actions: <Widget>[
          Visibility(
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => confirmDelete(context),
            ),
            visible: widget.visible?? false,
          ),
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Container(
        height: 270.0,
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Domaine : ${widget.domaine!.libelle}",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  EditDomaine(domaine: widget.domaine, visible: widget.visible?? false),
            ),
          ),
        ),
        visible: widget.visible?? false,
      ),
    );
  }
}
