// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import '../../main.dart';
import '../../models/salle.dart';
import '../../models/domaine.dart';
import '../../widgets/form_salle.dart';
import 'details.dart';


@immutable //cant alter once instancier
class EditSalle extends StatefulWidget {
  final Salle? salle;
  final Domaine? domaine;
  final bool? visible;
  // these variables are for initialize iniValues in Form
  const EditSalle({this.salle, this.domaine, this.visible});

  @override
  _EditState createState() => _EditState();
}

// all variables in this State is for creating SalleForm declared in Widgets
class _EditState extends State<EditSalle> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final formKey = GlobalKey<FormState>();

  // This is for text onChange
  late TextEditingController nomController;
  late TextEditingController capaciteController;
  //late Domaine value;
  late Domaine domaine;
  

  // Http post request
  //Future: to return a result of async function
  Future editSalle() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/salle/update.php"),
      body: {
        'id': widget.salle!.id.toString(),
        'nom': nomController.text,
        'capacite': capaciteController.text,
        'id_domaine': domaine.id.toString(),
      },
      //obligatory that in body use only 'string' if no jsonEncode
    );
  }
  //function to retrieve info of Salle after changed and send to DetailsSalle page
  Future<Salle> getSalle() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/salle/read_one.php"),
      body: {
        'id': widget.salle!.id.toString(),
      },
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      Salle salle = Salle.fromJson(item);
      return salle;
    } else {
      return Future.error('erreur serveur');
    }
  }

  void _onConfirm(context) async {
    await editSalle();
    Salle salle = await getSalle();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailsSalle(salle: salle, visible: widget.visible)));
  }

  @override
  void initState() {
    //user modifies a text field in TextEditingController, the text field updates value and the controller notifies its listeners
    nomController = TextEditingController(text: widget.salle!.nom);
    capaciteController =
        TextEditingController(text: widget.salle!.capacite.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Modifier la salle"),
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
            child: AppForm(
              formKey: formKey,
              nomController: nomController,
              capaciteController: capaciteController,
              value: widget.domaine,
              onChanged: (value) => setState(() {
                domaine = value!;
              }),
            ),
          ),
        ),
      ),
    );
  }
}
