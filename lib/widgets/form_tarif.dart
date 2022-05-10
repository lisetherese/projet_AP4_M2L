import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TarifForm extends StatefulWidget {
  // Required for form validations
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  // Handles text onchange
  TextEditingController? tarifController;
  TextEditingController? niveauController;

  // ignore: use_key_in_widget_constructors
  TarifForm({this.formKey, this.tarifController, this.niveauController});

  @override
  _TarifFormState createState() => _TarifFormState();
}

class _TarifFormState extends State<TarifForm> {
  //if verified correct => return null
  String? _validateTarif(String? value) {
    return value!.isEmpty ? 'Le tarif doit être défini' : null;
  }
  String? _validateNiveau(String? value) {
    RegExp regex = RegExp(r'(?<=\s|^)\d+(?=\s|$)');
    if (!regex.hasMatch(value!)) {
      return 'Le niveau du tarif doit être un chiffre';
    } else {
      return null;
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
            controller: widget.tarifController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              //allow only two decimal input number
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration: const InputDecoration(labelText: 'Tarif'),
            validator: _validateTarif,
          ),
          TextFormField(
            controller: widget.niveauController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Niveau Tarif'),
            validator: _validateNiveau,
          ),
        ],
      ),
    );
  }
}
