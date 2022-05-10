import 'package:flutter/material.dart';
import '../env.dart';
import '../models/domaine.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: must_be_immutable
class AppForm extends StatefulWidget {
  // Required for form validations
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  // Handles text onchange , add listeners
  TextEditingController? nomController;
  TextEditingController? capaciteController;
  void Function(Domaine?)? onChanged;
  Domaine? value;

  // ignore: use_key_in_widget_constructors
  AppForm(
      {this.formKey,
      this.nomController,
      this.capaciteController,
      this.value,
      required this.onChanged});

  @override
  _AppFormState createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  late Future<List<Domaine>> domaines;
  Domaine? domaine;

  @override
  void initState() {
    super.initState();
    domaines = getDomaineList();
  }

  String? _validateName(String? value) {
    return value!.isEmpty ? 'Nom de la salle doit être défini' : null;
  }

  String? _validateCapacite(String? value) {
    RegExp regex = RegExp(r'(?<=\s|^)\d+(?=\s|$)');
    if (!regex.hasMatch(value!)) {
      return 'La capacité de la salle doit être un chiffre';
    } else {
      return null;
    }
  }

  Future<List<Domaine>> getDomaineList() async {
    try {
      final response =
          await http.get(Uri.parse('${Env.URL_PREFIX}/domaine/read_all.php'));
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Domaine> domaines =
            items.map<Domaine>((json) => Domaine.fromJson(json)).toList();

        return domaines;
      } else {
        return Future.error('erreur serveur');
      }
    } catch (err) {
      return Future.error(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: widget.nomController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Nom'),
            validator: _validateName,
          ),
          TextFormField(
            controller: widget.capaciteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacité'),
            validator: _validateCapacite,
          ),
          FutureBuilder(
              future: domaines,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return AlertDialog(
                    content: Text('${snapshot.error}'),
                    actions: <Widget>[
                      ElevatedButton.icon(
                        label: const Text('OK'),
                        icon: const Icon(Icons.check),
                        autofocus: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<Domaine>(
                        decoration: const InputDecoration(
                          labelText: 'Nom de domaine',
                        ),
                        hint: const Text("Choisir un domaine"),
                        value:
                            widget.value, //=domaine: value can set to null or be one from the values list
                        isExpanded: true,
                        items: snapshot.data
                            .map<DropdownMenuItem<Domaine>>((domaine) {
                          return DropdownMenuItem<Domaine>(
                            child: Text(domaine.libelle),
                            value: domaine,
                          );
                        }).toList(),
                        onChanged: widget
                            .onChanged //take function onChanged defined in Widget on later use

                        ),
                  );
                }
                return const SizedBox();
              })
        ],
      ),
    );
  }
}
