// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../main.dart';
import '../../models/salle.dart';
import '../../models/domaine.dart';
import '../../models/tarif.dart';
import '../../models/reservation.dart';
import '../../widgets/form_reservation.dart';
import 'details.dart';

@immutable //cant alter once instancier
class EditReservation extends StatefulWidget {
  final Salle? salle;
  final Domaine? domaine;
  final Tarif? tarif;
  final Reservation? reservation;
  final bool? visible;

  const EditReservation(
      {this.salle, this.domaine, this.tarif, this.reservation, this.visible});

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<EditReservation> {
  final formKey = GlobalKey<FormState>();
  // This is for text onChange
  late TextEditingController breveDesController;
  late TextEditingController desCompleteController;
  late Tarif tarif;
  late Salle salle;
  late Domaine domaine;
  late String dateDebut;
  late String dateFin;
  late int etatConfirmation;
  late bool setFirstDate;

  // Http post request
  //Future: to return a result of async function
  Future editReservation() async {
    return await http.post(
      Uri.parse("${Env.URL_PREFIX}/reservation/update.php"),
      body: jsonEncode({
        "id": widget.reservation!.id,
        "breve_des": breveDesController.text,
        "des_complete": desCompleteController.text,
        "etat": etatConfirmation,
        "debut": dateDebut,
        "update": DateTime.now().toString(),
        "fin": dateFin,
        "idUser": widget.reservation!.idUser,
        "idTarif": tarif.id,
        "idSalle": salle.id,
        "idDomaine": domaine.id
      }),
      //obligatory that in body use only 'string' if no jsonEncode
    );
  }

  Future<Reservation> getReservation() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/reservation/read_one.php"),
      body: jsonEncode({
        "id": widget.reservation!.id,
      }),
    );
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      Reservation reservation = Reservation.fromJson(item);
      return reservation;
    } else {
      return Future.error('erreur serveur');
    }
  }

  void _onConfirm(context) async {
    await editReservation();
    Reservation reservation = await getReservation();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsReservation(
                reservation: reservation, visible: widget.visible)));
  }


  @override
  void initState() {
    //user modifies a text field in TextEditingController, the text field updates value and the controller notifies its listeners
    breveDesController =
        TextEditingController(text: widget.reservation!.breveDes);
    desCompleteController =
        TextEditingController(text: widget.reservation!.des);
    dateDebut = DateTime.parse(widget.reservation!.debut).toString();
    dateFin = DateTime.parse(widget.reservation!.fin).toString();
    etatConfirmation = widget.reservation!.etat;
    tarif = widget.tarif!;
    salle = widget.salle!;
    domaine = widget.domaine!;
    setFirstDate =  widget.visible?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Modifier la reservation"),
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
            child: ReservationForm(
              formKey: formKey,
              breveDesController: breveDesController,
              desCompleteController: desCompleteController,
              valueSalle: widget.salle,
              valueDomaine: widget.domaine,
              valueTarif: widget.tarif,
              visible: widget.visible ?? false,
              firstDateDebut: setFirstDate? DateTime(2022): DateTime.now(),
              firstDateFin: setFirstDate? DateTime(2022): DateTime.now(),
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
              onChangedTarif: (value) {
                setState(() {
                  tarif = value!;
                });
              },
              onChangedDomaine: (value) {
                setState(() {
                  domaine = value!;
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
            ),
          ),
        ),
      ),
    );
  }
}
