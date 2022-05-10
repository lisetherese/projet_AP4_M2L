import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/domaine.dart';

import '../../env.dart';
import '../../main.dart';
import '../../widgets/form_salle.dart';

@immutable
class CreateSalle extends StatefulWidget {
  const CreateSalle({Key? key}) : super(key: key);

  //final Function? refreshSalleList;

  // ignore: use_key_in_widget_constructors
  //const CreateSalle({this.refreshSalleList});

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreateSalle> {
  // Required for form validations
  final formKey = GlobalKey<FormState>();

  // Handles text onchange
  TextEditingController nomController = TextEditingController();
  TextEditingController capaciteController = TextEditingController();
  late Domaine value;
  late Domaine domaine; //later defined in onChanged of DropDownButton underneath

  // Http post request to create new data
  Future _createSalle() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/salle/create.php"),
      body: {
        "nom": nomController.text,
        "capacite": capaciteController.text,
        "id_domaine": domaine.id.toString(),
      },
    );
  }

  //if confirm, refresh the list and rebuild the route list
  void _onConfirm(context) async {
    await _createSalle();
    // Remove all existing routes until the Home.dart, then rebuild page.
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/listSalle', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Créer une salle"),
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
            child: AppForm(
              formKey: formKey,
              nomController: nomController,
              capaciteController: capaciteController,
              value: null,
              onChanged: (value) {
                domaine = value!;
              },
            ),
          ),
        ),
      ),
    );
  }
}
