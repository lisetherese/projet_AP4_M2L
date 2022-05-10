/*
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/user.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../../env.dart';
import '../../main.dart';
import '../../models/reservation.dart';
import '../../models/salle.dart';
import '../../models/user.dart';
import '../../models/domaine.dart';
import '../../models/tarif.dart';
import 'edit.dart';

@immutable
class DetailsReservation extends StatefulWidget {
  final Reservation? reservation;
  final bool? visible;

  // ignore: use_key_in_widget_constructors
  const DetailsReservation({this.reservation, this.visible});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<DetailsReservation> {
  late Future<Domaine> getOneDomaine;
  late Future<Salle> getOneSalle;
  late Future<Tarif> getOneTarif;
  late Domaine domaine;
  late Salle salle;
  late Tarif tarif;

  @override
  void initState() {
    getOneSalle = getSalle();
    getOneDomaine = getDomaine();
    getOneTarif = getTarif();
    super.initState();
  }

  void deleteReservation(context) async {
    await http.post(
      Uri.parse("${Env.URL_PREFIX}/reservation/delete.php"),
      body: jsonEncode({
        "id": widget.reservation!.id,
      }),
    );
    // Navigator.pop(context) = .push(context);
    //refresh after an API delete
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/listReservation', (Route<dynamic> route) => false);
  }

  void confirmDelete(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Vous êtes sûr de la supprimer?'),
          actions: <Widget>[
            ElevatedButton.icon(
              label: const Text('Non'),
              icon: const Icon(Icons.cancel),
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Oui"),
              onPressed: () => deleteReservation(context),
            ),
          ],
        );
      },
    );
  }

  Future<Salle> getSalle() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/salle/read_one.php"),
      body: {
        "id": widget.reservation!.idSalle.toString(),
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

  Future<Tarif> getTarif() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/tarif/read_one.php"),
      body: jsonEncode({
        "id": widget.reservation!.idTarif,
      }),
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      Tarif tarif = Tarif.fromJson(item);
      return tarif;
    } else {
      return Future.error('erreur serveur');
    }
  }

  Future<Domaine> getDomaine() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/read_one.php"),
      body: jsonEncode({
        "id": widget.reservation!.idDomaine,
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

  Future<User> getUser() async {
    final response = await http.get(Uri.parse(
        "${Env.URL_PREFIX}/user/read_one_user.php?id=${widget.reservation!.idUser}"));
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      User user = User.fromJson(item);
      return user;
    } else {
      return Future.error('erreur serveur');
    }
  }

  // to verify if the date début of reservation is already passé then cant modify or delete but admin can do that in any case
  bool checkDatePasse() {
    DateTime dateDebutRes = DateTime.parse(widget.reservation!.debut);
    if (widget.visible == true) {
      return true;
    } else {
      if (dateDebutRes.difference(DateTime.now()).isNegative) {
        return false;
      } else {
        return true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateD = DateFormat('dd/MM/yyyy HH:mm')
        .format(DateTime.parse(widget.reservation!.debut));
    String dateF = DateFormat('dd/MM/yyyy HH:mm')
        .format(DateTime.parse(widget.reservation!.fin));
    String dateU = DateFormat('dd/MM/yyyy HH:mm')
        .format(DateTime.parse(widget.reservation!.update));
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Détailles de la reservation'),
        actions: <Widget>[
          Visibility(
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => confirmDelete(context),
            ),
            visible: checkDatePasse(),
          ),
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                child: FutureBuilder<User>(
                  future: getUser(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email du créateur : ${snapshot.data!.email}",
                            style: const TextStyle(fontSize: 20),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Text(
                            "Id du créateur : ${snapshot.data!.id.toString()}",
                            style: const TextStyle(fontSize: 20),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
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
                    }
                    return const SizedBox();
                  },
                ),
                visible: widget.visible ?? false,
              ),
              Text(
                "Breve description : ${widget.reservation!.breveDes}",
                style: const TextStyle(fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              Text(
                "Description complète : \n ${widget.reservation!.des}",
                style: const TextStyle(fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              Text(
                "Etat confirmation : ${(widget.reservation!.etat == 0) ? "Non" : "Oui"}",
                style: const TextStyle(fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              // set condition to avoid showing dateTime update by default 1970 returned from DB
              if (DateFormat('yyyy')
                      .format(DateTime.parse(widget.reservation!.update)) !=
                  "1970")
                Text("Date heure update : $dateU",
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis),
              if (DateFormat('yyyy')
                      .format(DateTime.parse(widget.reservation!.update)) !=
                  "1970")
                const Padding(
                  padding: EdgeInsets.all(10),
                ),

              Text("Date heure début : $dateD",
                  style: const TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              Text("Date heure fin : $dateF",
                  style: const TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              FutureBuilder<Tarif>(
                future: getTarif(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(
                      "Tarif : ${snapshot.data!.tarif}",
                      style: const TextStyle(fontSize: 20),
                    );
                  } else if (snapshot.hasError) {
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
                  }
                  return const SizedBox();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              FutureBuilder<Domaine>(
                future: getDomaine(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(
                      "Domaine : ${snapshot.data!.libelle}",
                      style: const TextStyle(fontSize: 20),
                    );
                  } else if (snapshot.hasError) {
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
                  }
                  return const SizedBox();
                },
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
              FutureBuilder<Salle>(
                future: getSalle(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return Text(
                      "Salle : ${snapshot.data!.nom}",
                      style: const TextStyle(fontSize: 20),
                    );
                  } else if (snapshot.hasError) {
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
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              // edit EditReservation here!
              builder: (BuildContext context) => EditReservation(
                  reservation: widget.reservation,
                  visible: widget.visible ?? false,
                  salle: salle!,
                  tarif: tarif!,
                  domaine: domaine!),
            ),
          ),
        ),
        visible: checkDatePasse(),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //Encoders and decoders for converting between different data
import '../../env.dart'; //to use the link to api in php
import '../../models/reservation.dart'; // to use class Reservation created
import '../reservations_screens/details.dart'; // to access to function to delete reservation
import '../reservations_screens/create.dart'; //to access to create Reservation
import '../../main.dart';
class ListReservation extends StatefulWidget {
  const ListReservation({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
}


List<Reservation> _searchResult = [];
List<Reservation> _allReservations = [];


class _ListState extends State<ListReservation> {
  //late modifier can be used while declaring a non-nullable variable that's initialized after its declaration
  late Future<List<Reservation>> reservations;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final reservationListKey = GlobalKey<_ListState>();
  var visible = false;

  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    reservations = getReservations();
  }
  /* trong function thong thuong thi goi async bang name().then() 
   * trong function async khac thi goi bang await va phai define return value as Future<type>
  */
  Future<int> getIdUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id') ?? 0;
  }

  Future<String> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? '';
  }

  // function to set the list of reservations shown up according to user, admin can see all but user can only see their res which have same idUser
  Future<List<Reservation>> getReservations() async {
    try {
      final String role = await getRole();
      setState(() {
        visible = role == 'admin' ? true : false;
      });
      if (role == "admin") {
        return getReservationList();
      } else {
        final int idUser = await getIdUser();
        return getReservationsById(idUser);
      }
    } catch (err) {
      return Future.error(err);
    }
  }
  onSearchTextChanged(String text) async {
    _searchResult.clear();

    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var reservation in _allReservations) {
      if (reservation.breveDes.contains(text) || reservation.des.contains(text) || reservation.debut.contains(text) || reservation.fin.contains(text)) {
        _searchResult.add(reservation);
      }
    }
    setState(() {});
  }


  Future<List<Reservation>> getReservationList() async {
    try {
      final response = await http
          .get(Uri.parse('${Env.URL_PREFIX}/reservation/read_all.php'));
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Reservation> reservations = items
            .map<Reservation>((json) => Reservation.fromJson(json))
            .toList();

        return reservations;
      } else {
        return Future.error('erreur serveur');
      }
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<List<Reservation>> getReservationsById(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.URL_PREFIX}/reservation/read_by_user.php'),
        body: jsonEncode({
          "idUser": id,
        }),
      );
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Reservation> reservations = items
            .map<Reservation>((json) => Reservation.fromJson(json))
            .toList();

        return reservations;
      } else {
        return Future.error('erreur serveur');
      }
    } catch (err) {
      return Future.error(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      key: reservationListKey,
      appBar: AppBar(
        title: const Text('Liste des reservations'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Reservation>>(
          future: reservations,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return AlertDialog(
                content: const Text("Il n'y a aucun reservation dans la liste"),
                actions: <Widget>[
                  ElevatedButton.icon(
                    label: const Text('Ajouter'),
                    icon: const Icon(Icons.playlist_add_outlined),
                    autofocus: true,
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return CreateReservation(visible: visible);
                      }))
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError) {
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
              // Render reservation lists
              return Column(mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            snapshot.data == null ? 0 : snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          var data = snapshot.data[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.bookmark,
                                color: jaune,
                                size: 30,
                              ),
                              trailing: const Icon(Icons.view_list),
                              title: Text(
                                data.breveDes,
                                style: const TextStyle(fontSize: 20),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailsReservation(
                                          reservation: data, visible: visible)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                     FloatingActionButton(
                        mouseCursor: MaterialStateMouseCursor.clickable,
                        child: const Icon(Icons.add),
                        splashColor: Colors.red,
                        hoverColor: Colors.red,
                        highlightElevation: 50,
                        elevation: 12,
                        tooltip: 'Ajouter reservation',
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return CreateReservation(visible: visible,);
                          }));
                        },
                      ),
                  ]);
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

*/
/*
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
  late Future<List<Salle>> salles;
  late Future<List<Domaine>> domaines;
  late Future<List<Tarif>> tarifs;
  //to take value onChanged to inject in DB
  Salle? salle;
  Domaine? domaine;
  Tarif? tarif;
  DateTime? dateDebut;
  DateTime? dateFin;

  @override
  void initState() {
    super.initState();
    salles = getSalleList();
    domaines = getDomaineList();
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

  Future<List<Salle>> getSalleList() async {
    try {
      final response =
          await http.get(Uri.parse('${Env.URL_PREFIX}/salle/read_all.php'));
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Salle> salles =
            items.map<Salle>((json) => Salle.fromJson(json)).toList();

        return salles;
      } else {
        return Future.error('erreur serveur');
      }
    } catch (err) {
      return Future.error(err);
    }
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
    if (salle != null) {
      try {
        final response =
            await http.get(Uri.parse('${Env.URL_PREFIX}/domaine/read_all.php'));
        if (response.statusCode == 200) {
          final items = json.decode(response.body);
          List<Domaine> results =
              items.map<Domaine>((json) => Domaine.fromJson(json)).toList();

          for (Domaine domaine in results) {
            if(domaine.id == salle.idDomaine) {
              return domaines.add()
            }
          }

          return domaines;
        } else {
          return Future.error('erreur serveur');
        }
      } catch (err) {
        return Future.error(err);
      }
    }
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
                            labelText: 'Nom du domaine *',
                          ),
                          hint: const Text("Choisir un domaine"),
                          value: widget.valueDomaine,
                          isExpanded: true,
                          items: snapshot.data
                              .map<DropdownMenuItem<Domaine>>((domaine) {
                            return DropdownMenuItem<Domaine>(
                              child: Text(domaine.libelle),
                              value: domaine,
                            );
                          }).toList(),
                          onChanged: widget.onChangedDomaine),
                    );
                  }
                  return const SizedBox();
                }),
            FutureBuilder(
                future: salles,
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
                      child: DropdownButtonFormField<Salle>(
                          decoration: const InputDecoration(
                            labelText: 'Nom de la salle *',
                          ),
                          hint: const Text("Choisir une salle"),
                          value: widget.valueSalle,
                          isExpanded: true,
                          items: snapshot.data
                              .map<DropdownMenuItem<Salle>>((salle) {
                            return DropdownMenuItem<Salle>(
                              child: Text(salle.nom),
                              value: salle,
                            );
                          }).toList(),
                          onChanged: widget.onChangedSalle),
                    );
                  }
                  return const SizedBox();
                }),
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

*/

/* file create reservation original still working
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/salle.dart';
import 'package:test_app/models/domaine.dart';
//import 'package:intl/intl.dart';
import '../../env.dart';
import '../../main.dart';
import '../../models/tarif.dart';
import '../../widgets/form_reservation.dart';

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
  late Salle salle;
  late Domaine domaine;
  String dateDebut =  DateTime.now().add(const Duration(hours: 1)).toString();
  String dateFin =  DateTime.now().add(const Duration(hours: 2)).toString();
  //set value of etat at beginning to avoid user not toggle button
  int etatConfirmation = 0;
  //set inital value for DateDebut to avoid error for validator on loading
  String dateDe = DateTime.now().toString();

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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ReservationForm(
              formKey: formKey,
              breveDesController: breveDesController,
              desCompleteController: desCompleteController,
              valueSalle: null,
              valueDomaine: null,
              visible: widget.visible ?? false,
              onToggleEtat: (index) {
                etatConfirmation = index!;
              },
              initialValueDebut: dateDebut,
              onChangedDateDebut: (value) {
                dateDebut = value!;
              },
              initialValueFin: dateFin,
              onChangedDateFin: (value) {
                dateFin = value!;
              },
              onChangedSalle: (value) {
                setState(() {
                  salle = value!;
                });
              },
              onChangedValidate: (value) {
                DateTime dateF = DateTime.parse(value!);
                DateTime dateD = DateTime.parse(dateDebut);
                if (dateF.difference(dateD).inMinutes.round() < 0) {
                  return 'Date heure déjà passée';
                } else if (dateF.difference(dateD).inMinutes.round() < 60) {
                  return "Au moins une heure!";
                }
                return null;
              },
              onChangedDomaine: (value) {
               setState(() {
                  domaine = value!;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

*/