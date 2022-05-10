import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DomaineForm extends StatefulWidget {
  // Required for form validations
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  // Handles text onchange , add listeners
  TextEditingController? libelleController;
  

  // ignore: use_key_in_widget_constructors
  DomaineForm(
      {this.formKey,
      this.libelleController
      });

  @override
  _DomaineFormState createState() => _DomaineFormState();
}

class _DomaineFormState extends State<DomaineForm> {
  
  String? _validateLibelle(String? value) {
    return value!.isEmpty ? 'Libelle du domaine doit être défini' : null;
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: widget.libelleController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: 'Libelle'),
            validator: _validateLibelle,
          ),
          
        ],
      ),
    );
  }
}
