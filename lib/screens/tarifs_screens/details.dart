//import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import '../../main.dart';
import '../../models/tarif.dart';
import 'edit.dart';

@immutable
class DetailsTarif extends StatefulWidget {
  final Tarif? tarif;
  final bool? visible;

  // ignore: use_key_in_widget_constructors
  const DetailsTarif({this.tarif, this.visible});

  @override
  _DetailsState createState() => _DetailsState();
}


class _DetailsState extends State<DetailsTarif> {
  

  void deleteTarif(context) async {
    await http.post(
      Uri.parse("${Env.URL_PREFIX}/tarif/delete.php"),
      body: jsonEncode({
        "id": widget.tarif!.id,
      }),
    );
    // Navigator.pop(context) = .push(context);
    //refresh after an API delete
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/listTarif', (Route<dynamic> route) => false);
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
              onPressed: () => deleteTarif(context),
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
        title: const Text('Détailles du tarif'),
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
              "Tarif : ${widget.tarif!.tarif}",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "Niveau Tarif : ${widget.tarif!.niveau}",
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
              builder: (BuildContext context) => EditTarif(tarif: widget.tarif, visible: widget.visible?? false,),
            ),
          ),
        ),
        visible: widget.visible?? false,
      ),
    );
  }
}
