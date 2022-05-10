import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/salle.dart';
import 'package:test_app/models/domaine.dart';
import 'package:toggle_switch/toggle_switch.dart';
//import 'package:intl/intl.dart';
import '../../env.dart';
import '../../main.dart';
import '../../models/tarif.dart';
//import '../../widgets/form_reservation.dart';

@immutable
class CreateReservation extends StatefulWidget {
  final bool? visible;
  // ignore: use_key_in_widget_constructors
  const CreateReservation({this.visible});
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreateReservation> {
  // Required for form validations
  final formKey = GlobalKey<FormState>();

  // Handles text onchange
  TextEditingController breveDesController = TextEditingController();
  TextEditingController desCompleteController = TextEditingController();
  Salle salle = Salle(id: 0, nom: 'abc', capacite: 0, idDomaine: 0);
  Domaine domaine = Domaine(id: 0, libelle: 'abc');
  late Tarif tarif;
  String dateDebut = DateTime.now().add(const Duration(hours: 1)).toString();
  String dateFin = DateTime.now().add(const Duration(hours: 2)).toString();
  //set value of etat at beginning to avoid user not toggle button
  int etatConfirmation = 0;
  //set inital value for DateDebut to avoid error for validator on loading
  String dateDe = DateTime.now().toString();

  //to show values in dropDownButton
  late Future<List<Domaine>> domaines;
  late Future<List<Salle>> salles;
  late Future<List<Tarif>> tarifs;

  @override
  void initState() {
    super.initState();
    salles = getSalleList(domaine);
    domaines = getDomaineList(salle);
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

  Future<List<Salle>> getSalleList(Domaine? domaine) async {
    final response =
        await http.get(Uri.parse('${Env.URL_PREFIX}/salle/read_all.php'));
    final items = json.decode(response.body);

    List<Salle> salles = domaine!.id == 0
        ? items.map<Salle>((json) => Salle.fromJson(json)).toList()
        : items
            .map<Salle>((json) => Salle.fromJson(json))
            .where((e) => e.idDomaine == domaine.id)
            .toList();
    return salles;
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

  Future<List<Domaine>> getDomaineList(Salle? salle) async {
    final response =
        await http.get(Uri.parse('${Env.URL_PREFIX}/domaine/read_all.php'));
    final items = json.decode(response.body);

    List<Domaine> domaines = salle!.id == 0
        ? items.map<Domaine>((json) => Domaine.fromJson(json)).toList()
        : items
            .map<Domaine>((json) => Domaine.fromJson(json))
            .where((e) => e.id == salle.idDomaine)
            .toList();
    return domaines;
  }

  // Http post request to create new data
  Future _createReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var idUser = prefs.getInt("id");
    var niveauTarif = prefs.getInt("tarif");
    final response =
        await http.post(Uri.parse("${Env.URL_PREFIX}/tarif/read_by_niveau.php"),
            body: jsonEncode({
              "niveau": niveauTarif,
            }));
    final item = json.decode(response.body);
    Tarif tarif = Tarif.fromJson(item);
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/reservation/create.php"),
      body: jsonEncode({
        "breve_des": breveDesController.text,
        "des_complete": desCompleteController.text,
        "etat": etatConfirmation,
        "debut": dateDebut,
        "fin": dateFin,
        "idUser": idUser,
        "idTarif": tarif.id,
        "idSalle": salle.id,
        "idDomaine": domaine.id
      }),
    );
  }

  //if confirm, refresh the list and rebuild the route '/' home
  void _onConfirm(context) async {
    await _createReservation();
    // Remove all existing routes until the Home.dart, then rebuild Home.
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/listReservation', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Créer une reservation"),
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
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: breveDesController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Brève description *'),
                      validator: _validateDes,
                    ),
                    TextField(
                      controller: desCompleteController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          labelText: 'Description complète *'),
                      maxLines: 4,
                      onChanged: _validateDesCom,
                    ),
                    DateTimePicker(
                      type: DateTimePickerType.dateTimeSeparate,
                      autovalidate: true,
                      dateMask: 'dd / MM / yyyy',
                      initialValue: dateDebut,
                      firstDate:
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
                      onChanged: (value) {
                        dateDebut = value;
                      },
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
                      initialValue: dateFin,
                      firstDate: DateTime.now(),
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
                      onChanged: (value) {
                        dateFin = value;
                      },
                      validator: (value) {
                        DateTime dateF = DateTime.parse(value!);
                        DateTime dateD = DateTime.parse(dateDebut);
                        if (dateF.difference(dateD).inMinutes.round() < 0) {
                          return 'Date heure déjà passée';
                        } else if (dateF.difference(dateD).inMinutes.round() <
                            60) {
                          return "Au moins une heure!";
                        }
                        return null;
                      },
                      onSaved: (val) {},
                    ),
                    FutureBuilder(
                        future: domaines,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                                  labelText: 'Nom du domaine *',
                                ),
                                hint: const Text("Choisir un domaine"),
                                value: null,
                                isExpanded: true,
                                items: snapshot.data
                                    .map<DropdownMenuItem<Domaine>>((domaine) {
                                  return DropdownMenuItem<Domaine>(
                                    child: Text(domaine.libelle),
                                    value: domaine,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState((() {
                                    domaine = value!;
                                    salles = getSalleList(domaine);
                                  }));
                                },
                              ),
                            );
                          }
                          return const SizedBox();
                        }),
                    FutureBuilder(
                        future: salles,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
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
                              child: DropdownButtonFormField<Salle>(
                                decoration: const InputDecoration(
                                  labelText: 'Nom de la salle *',
                                ),
                                hint: const Text("Choisir une salle"),
                                value: null,
                                isExpanded: true,
                                items: snapshot.data
                                    .map<DropdownMenuItem<Salle>>((salle) {
                                  return DropdownMenuItem<Salle>(
                                    child: Text(salle.nom),
                                    value: salle,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState((() {
                                    salle = value!;
                                    //domaines = getDomaineList(salle);
                                  }));
                                },
                              ),
                            );
                          }
                          return const SizedBox();
                        }),
                    Visibility(
                      child: FutureBuilder(
                          future: tarifs,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return AlertDialog(
                                content: Text('${snapshot.error}'),
                                actions: <Widget>[
                                  ElevatedButton.icon(
                                    label: const Text('OK'),
                                    icon: const Icon(Icons.check),
                                    autofocus: true,
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
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
                                    value: null,
                                    isExpanded: true,
                                    items: snapshot.data
                                        .map<DropdownMenuItem<Tarif>>((tarif) {
                                      return DropdownMenuItem<Tarif>(
                                        child: Text(tarif.tarif.toString()),
                                        value: tarif,
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState((() => tarif = value!));
                                    }),
                              );
                            }
                            return const SizedBox();
                          }),
                      visible: widget.visible ?? false,
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
                            initialLabelIndex: 0,
                            totalSwitches: 2,
                            minWidth: 90.0,
                            cornerRadius: 20.0,
                            activeBgColors: const [
                              [rouge],
                              [jaune]
                            ],
                            activeFgColor: Colors.white,
                            inactiveBgColor:
                                const Color.fromARGB(255, 197, 195, 195),
                            inactiveFgColor: Colors.white,
                            labels: const [
                              'Non',
                              'Oui',
                            ],
                            radiusStyle: true,
                            onToggle: (index) {
                              etatConfirmation = index!;
                            },
                          ),
                        ],
                      ),
                      visible: widget.visible ?? false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
