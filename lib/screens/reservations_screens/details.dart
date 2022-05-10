import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/user.dart';
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
 
  late Domaine? domaine;
  late Salle? salle;
  late Tarif? tarif;


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
                    tarif = snapshot.data;
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
                    domaine = snapshot.data;
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
                    salle = snapshot.data;
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
