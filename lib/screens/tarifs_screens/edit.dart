// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../main.dart';
import '../../models/tarif.dart';
import '../../widgets/form_tarif.dart';
import 'details.dart';

@immutable //cant alter once instancier
class EditTarif extends StatefulWidget {
  final Tarif? tarif;
  final bool? visible;

  const EditTarif({this.tarif, this.visible});

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditTarif> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final formKey = GlobalKey<FormState>();

  // This is for text onChange
  late TextEditingController tarifController;
  late TextEditingController niveauController;

  // Http post request
  //Future: to return a result of async function
  Future editTarif() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/tarif/update.php"),
      body: jsonEncode({
        "id": widget.tarif!.id,
        "tarif": tarifController.text,
        "niveau": niveauController.text
      }),
      //obligatory that in body use only 'key'
    );
  }

  Future<Tarif> getTarif() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/tarif/read_one.php"),
      body: jsonEncode({
        "id": widget.tarif!.id,
      }),
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      Tarif tarif = Tarif.fromJson(item);
      return tarif;
    } else {
      return Future.error('erreur serveur');
    }
  }

  void _onConfirm(context) async {
    await editTarif();
    Tarif tarif = await getTarif();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DetailsTarif(tarif: tarif, visible: widget.visible)));
  }

  @override
  void initState() {
    //user modifies a text field in TextEditingController, the text field updates value and the controller notifies its listeners
    tarifController =
        TextEditingController(text: widget.tarif!.tarif.toString());
    niveauController =
        TextEditingController(text: widget.tarif!.niveau.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Modifier le tarif"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          child: const Text('CONFIRMER'),
          onPressed: () {
            _onConfirm(context);
          },
        ),
      ),
      body: Container(
        height: double.infinity, //as big as the parent
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TarifForm(
              formKey: formKey,
              tarifController: tarifController,
              niveauController: niveauController,
            ),
          ),
        ),
      ),
    );
  }
}
