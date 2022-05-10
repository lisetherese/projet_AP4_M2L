import 'package:flutter/material.dart';
import 'package:test_app/models/tarif.dart';
import '../env.dart';
import '../models/salle.dart';
import '../models/domaine.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';
import 'dart:convert';
import 'package:toggle_switch/toggle_switch.dart';
import '../main.dart';

// ignore: must_be_immutable
class ReservationForm extends StatefulWidget {
  // Required for form validations
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  // Handles text onchange , add listeners
  TextEditingController? breveDesController;
  TextEditingController? desCompleteController;

  void Function(Tarif?)? onChangedTarif;
  void Function(Salle?)? onChangedSalle;
  void Function(Domaine?)? onChangedDomaine;
  void Function(String?)? onChangedDateDebut;
  void Function(String?)? onChangedDateFin;
  String? Function(String?)? onChangedValidate;
  void Function(int?)? onToggleEtat;
  DateTime? firstDateDebut;
  DateTime? firstDateFin;
  Domaine? valueDomaine;
  Salle? valueSalle;
  Tarif? valueTarif;
  bool visible;
  String? initialValueDebut;
  String? initialValueFin;
  int? initialValueToggle;

  // ignore: use_key_in_widget_constructors
  ReservationForm(
      {this.formKey,
      this.valueSalle,
      required this.visible,
      this.firstDateDebut,
      this.firstDateFin,
      this.valueDomaine,
      this.valueTarif,
      this.initialValueToggle,
      required this.initialValueDebut,
      required this.initialValueFin,
      required this.breveDesController,
      required this.desCompleteController,
      this.onChangedTarif,
      required this.onChangedSalle,
      required this.onChangedDomaine,
      required this.onChangedDateDebut,
      required this.onChangedValidate,
      required this.onChangedDateFin,
      required this.onToggleEtat});

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  //to show values in dropDownButton
  List<Domaine> _allDomaines = [];
  List<Salle> _allSalles = [];
  late Future<List<Tarif>> tarifs;
  //to take value onChanged to inject in DB
  Salle? salle;
  Domaine? domaine;
  /*Tarif? tarif;
  DateTime? dateDebut;
  DateTime? dateFin;*/

  @override
  void initState() {
    super.initState();
    salle = widget.valueSalle;
    domaine = widget.valueDomaine;
    getSalleList(domaine!);
    getDomaineList(salle!);
    tarifs = getTarifList();
  }

  String? _validateDes(String? value) {
    return value!.isEmpty
        ? 'Breve description de la reservation doit être défini'
        : null;
  }

  String? _validateDesCom(String? value) {
    return value!.isEmpty
        ? 'Description complète de la reservation doit être défini'
        : null;
  }

  Future<void> getSalleList(Domaine? domaine) async {
    final response =
        await http.get(Uri.parse('${Env.URL_PREFIX}/salle/read_all.php'));
    final items = json.decode(response.body);
    setState(() {
      _allSalles = domaine != null
          ? items.map<Salle>((json) => Salle.fromJson(json)).toList()
          : items
              .map<Salle>((json) => Salle.fromJson(json))
              .where((e) => e['id_domaine'] == domaine!.id)
              .toList();
    });
  }

  Future<List<Tarif>> getTarifList() async {
    try {
      final response =
          await http.get(Uri.parse('${Env.URL_PREFIX}/tarif/read_all.php'));
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Tarif> tarifs =
            items.map<Tarif>((json) => Tarif.fromJson(json)).toList();

        return tarifs;
      } else {
        return Future.error('erreur serveur');
      }
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<void> getDomaineList(Salle? salle) async {
    final response =
        await http.get(Uri.parse('${Env.URL_PREFIX}/domaine/read_all.php'));
    final items = json.decode(response.body);

    setState(() {
      _allDomaines = salle != null
          ? items.map<Domaine>((json) => Domaine.fromJson(json)).toList()
          : items
              .map<Domaine>((json) => Domaine.fromJson(json))
              .where((e) => e['id'] == salle!.idDomaine)
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: widget.breveDesController,
              keyboardType: TextInputType.text,
              decoration:
                  const InputDecoration(labelText: 'Brève description *'),
              validator: _validateDes,
            ),
            TextField(
              controller: widget.desCompleteController,
              keyboardType: TextInputType.multiline,
              decoration:
                  const InputDecoration(labelText: 'Description complète *'),
              maxLines: 4,
              onChanged: _validateDesCom,
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              autovalidate: true,
              dateMask: 'dd / MM / yyyy',
              initialValue: widget.initialValueDebut,
              firstDate: widget.firstDateDebut ??
                  DateTime.now(), //.subtract(const Duration(days: 1)),
              lastDate: DateTime(2025),
              icon: const Icon(Icons.event),
              dateLabelText: 'Date début *',
              timeLabelText: "Heure début *",
              selectableDayPredicate: (date) {
                // Disable weekend days to select from the calendar
                if (date.weekday == 6 || date.weekday == 7) {
                  return false;
                }
                return true;
              },
              onChanged: widget.onChangedDateDebut,
              validator: (selectedDate) {
                if (selectedDate != null) {
                  DateTime selected = DateTime.parse(selectedDate);
                  if (selected.difference(DateTime.now()).isNegative) {
                    return 'Date sélectionné a été passée';
                  }
                } else {
                  return "Date ne peut être vide";
                }
                return null;
              },
              onSaved: (val) {},
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              autovalidate: true,
              dateMask: 'dd / MM / yyyy',
              initialValue: widget.initialValueFin,
              firstDate: widget.firstDateFin ?? DateTime.now(),
              lastDate: DateTime(2025),
              icon: const Icon(Icons.event),
              dateLabelText: 'Date fin *',
              timeLabelText: "Heure fin *",
              selectableDayPredicate: (date) {
                // Disable weekend days to select from the calendar
                if (date.weekday == 6 || date.weekday == 7) {
                  return false;
                }

                return true;
              },
              onChanged: widget.onChangedDateFin,
              validator: widget.onChangedValidate,
              onSaved: (val) {},
            ),
             _allDomaines.isNotEmpty ?
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<Domaine>(
                          decoration: const InputDecoration(
                            labelText: 'Nom du domaine *',
                          ),
                          hint: const Text("Choisir un domaine"),
                          value: widget.valueDomaine,
                          isExpanded: true,
                          items: _allDomaines
                              .map<DropdownMenuItem<Domaine>>((domaine) {
                            return DropdownMenuItem<Domaine>(
                              child: Text(domaine.libelle),
                              value: domaine,
                            );
                          }).toList(),
                          onChanged: widget.onChangedDomaine),
                    ):
                    const SizedBox(),
                    
            _allSalles.isNotEmpty ?
           DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<Salle>(
                          decoration: const InputDecoration(
                            labelText: 'Nom de la salle *',
                          ),
                          hint: const Text("Choisir une salle"),
                          value: widget.valueSalle,
                          isExpanded: true,
                          items: _allSalles
                              .map<DropdownMenuItem<Salle>>((salle) {
                            return DropdownMenuItem<Salle>(
                              child: Text(salle.nom),
                              value: salle,
                            );
                          }).toList(),
                          onChanged: widget.onChangedSalle),
                    ): const SizedBox(),

            Visibility(
              child: FutureBuilder(
                  future: tarifs,
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
                        child: DropdownButtonFormField<Tarif>(
                            decoration: const InputDecoration(
                              labelText: 'Tarif *',
                            ),
                            hint: const Text("Choisir un tarif"),
                            value: widget.valueTarif,
                            isExpanded: true,
                            items: snapshot.data
                                .map<DropdownMenuItem<Tarif>>((tarif) {
                              return DropdownMenuItem<Tarif>(
                                child: Text(tarif.tarif.toString()),
                                value: tarif,
                              );
                            }).toList(),
                            onChanged: widget.onChangedTarif),
                      );
                    }
                    return const SizedBox();
                  }),
              visible: widget.visible,
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              child: Row(
                children: [
                  const Text(
                    'Etat confirmation',
                    style: TextStyle(
                      color: grey,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ToggleSwitch(
                    initialLabelIndex: widget.initialValueToggle ?? 0,
                    totalSwitches: 2,
                    minWidth: 90.0,
                    cornerRadius: 20.0,
                    activeBgColors: const [
                      [rouge],
                      [jaune]
                    ],
                    activeFgColor: Colors.white,
                    inactiveBgColor: const Color.fromARGB(255, 197, 195, 195),
                    inactiveFgColor: Colors.white,
                    labels: const [
                      'Non',
                      'Oui',
                    ],
                    radiusStyle: true,
                    onToggle: widget.onToggleEtat,
                  ),
                ],
              ),
              visible: widget.visible,
            ),
          ],
        ),
      ),
    );
  }
}
