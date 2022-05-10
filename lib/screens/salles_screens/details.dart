import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../env.dart';
import '../../main.dart';
import '../../models/salle.dart';
import '../../models/domaine.dart';
import 'edit.dart';

@immutable
class DetailsSalle extends StatefulWidget {
  final Salle? salle;
  final bool? visible;

  // ignore: use_key_in_widget_constructors
  const DetailsSalle({this.salle, this.visible});

  @override
  _DetailsState createState() => _DetailsState();
}


class _DetailsState extends State<DetailsSalle> {
  late Domaine? domaine;

 
  void deleteSalle(context) async {
    await http.post(
      Uri.parse("${Env.URL_PREFIX}/salle/delete.php"),
      body: {
        'id': widget.salle!.id.toString(),
      },
    );
    // Navigator.pop(context) = .push(context);
    //refresh after an API delete
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/listSalle', (Route<dynamic> route) => false);
  }

  void confirmDelete(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Vous êtes sûr de le supprimer?'),
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
              onPressed: () => deleteSalle(context),
            ),
          ],
        );
      },
    );
  }

  Future<Domaine> getNomDomaine() async {
    final response = await http.post(
      Uri.parse("${Env.URL_PREFIX}/domaine/read_one.php"),
      body: jsonEncode({
        "id": widget.salle!.idDomaine,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Détailles de la salle'),
        actions: <Widget>[
          Visibility(child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => confirmDelete(context),
          ),
           visible: widget.visible?? false,
          ),
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Container(
        height: 270.0,
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Nom : ${widget.salle!.nom}",
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            Text(
              "Capacité : ${widget.salle!.capacite}",
              style: const TextStyle(fontSize: 20),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            FutureBuilder<Domaine>(
              future: getNomDomaine(),
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
          ],
        ),
      ),
      floatingActionButton: Visibility(child:FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => EditSalle(salle: widget.salle, domaine: domaine!, visible: widget.visible?? false),
          ),
        ),
      ),
      visible: widget.visible?? false,
      ),
    );
  }
}
