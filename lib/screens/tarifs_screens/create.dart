import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../main.dart';
import '../../widgets/form_tarif.dart';

@immutable
class CreateTarif extends StatefulWidget {
  final Function? refreshTarifList;

  // ignore: use_key_in_widget_constructors
  const CreateTarif({this.refreshTarifList});

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreateTarif> {
  // Required for form validations
  final formKey = GlobalKey<FormState>();

  // Handles text onchange
  TextEditingController tarifController = TextEditingController();
  TextEditingController niveauController = TextEditingController();
  

  // Http post request to create new data
  Future _createTarif() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/tarif/create.php"),
      body: jsonEncode({
        "tarif": double.parse(tarifController.text),
        "niveau": int.parse(niveauController.text),
      }),
    );
  }

  //if confirm, refresh the list and rebuild the route '/tarif' home
  void _onConfirm(context) async {
    await _createTarif();
    // Remove all existing routes until the Tarif.dart, then rebuild Tarif.
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/listTarif', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Créer un tarif"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          child: const Text("CONFIRMER"),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _onConfirm(context);
            }
          },
        ),
      ),
      body: Container(
        height: double.infinity,
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
