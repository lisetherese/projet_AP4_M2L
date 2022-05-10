import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../main.dart';
import '../../widgets/form_domaine.dart';

@immutable
class CreateDomaine extends StatefulWidget {
  const CreateDomaine({Key? key}) : super(key: key);
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreateDomaine> {
  // Required for form validations
  final formKey = GlobalKey<FormState>();

  // Handles text onchange
  TextEditingController libelleController = TextEditingController();

  // Http post request to create new data
  Future _createDomaine() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/create.php"),
      body: jsonEncode({
        "libelle": libelleController.text,
      }),
    );
  }

  //if confirm, refresh the list and rebuild the route '/domaine' home
  void _onConfirm(context) async {
    await _createDomaine();
    // Remove all existing routes until the Domaine.dart, then rebuild Domaine.
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/listDomaine', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Créer un domaine"),
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
            child: DomaineForm(
              formKey: formKey,
              libelleController: libelleController,
            ),
          ),
        ),
      ),
    );
  }
}
