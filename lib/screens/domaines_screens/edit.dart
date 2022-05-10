// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import '../../main.dart';
import '../../models/domaine.dart';
import '../../widgets/form_domaine.dart';
import 'details.dart';

@immutable //cant alter once instancier
class EditDomaine extends StatefulWidget {
  final Domaine? domaine;
  final bool? visible;

  const EditDomaine({this.domaine, this.visible});

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditDomaine> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final formKey = GlobalKey<FormState>();

  // This is for text onChange
  late TextEditingController libelleController;

  // Http post request
  //Future: to return a result of async function
  Future editDomaine() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/update.php"),
      body: jsonEncode(
          {"id": widget.domaine!.id, "libelle": libelleController.text}),
      //obligatory that in body use only 'key'
    );
  }

  Future<Domaine> getDomaine() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/read_one.php"),
      body: jsonEncode({
        "id": widget.domaine!.id,
      }),
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      Domaine domaine = Domaine.fromJson(item);
      return domaine;
    } else {
      return Future.error('erreur serveur');
    }
  }

  void _onConfirm(context) async {
    // waiting to modify in DB
    await editDomaine();
    //redefine variable domaine in widget
    Domaine domaine = await getDomaine();
    //then send that new domaine to details page to be shown
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsDomaine(domaine: domaine, visible: widget.visible)));
  }

  @override
  void initState() {
    //user modifies a text field in TextEditingController, the text field updates value and the controller notifies its listeners
    libelleController =
        TextEditingController(text: widget.domaine!.libelle.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Modifier le domaine"),
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
