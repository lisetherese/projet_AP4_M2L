import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //Encoders and decoders for converting between different data

import '../../env.dart'; //to use the link to api in php
import '../../models/tarif.dart'; // to use class Tarif created
import '../tarifs_screens/details.dart'; // to access to function to delete tarif
import '../tarifs_screens/create.dart'; //to access to create Tarif
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main.dart';

class ListTarif extends StatefulWidget {
  const ListTarif({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
}



class _ListState extends State<ListTarif> {
  //late modifier can be used while declaring a non-nullable variable that's initialized after its declaration
  late Future<List<Tarif>> tarifs;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final tarifListKey = GlobalKey<_ListState>();
  //set visibility to certain widgets selon role = 'admin' or not
  bool visible = false;

  @override
  void initState() {
    super.initState();
    tarifs = getTarifList();
    
  }

  Future<String> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? '';
  }
  
  Future<List<Tarif>> getTarifList() async {
    try {
      final String role = await getRole();
      setState(() {
        visible = role == 'admin' ? true : false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      key: tarifListKey,
      appBar: AppBar(
        title: const Text('Liste des tarifs'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Tarif>>(
          future: tarifs,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return AlertDialog(
                content: const Text("Il n'y a aucun tarif dans la liste"),
                actions: <Widget>[
                  Visibility(
                    child: ElevatedButton.icon(
                    label: const Text('Ajouter'),
                    icon: const Icon(Icons.playlist_add_outlined),
                    autofocus: true,
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return const CreateTarif();
                      }))
                    },
                  ),
                  visible: visible,
                    replacement: ElevatedButton.icon(
                      label: const Text('OK'),
                      icon: const Icon(Icons.check),
                      autofocus: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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
              // Render tarif lists
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
                              leading: const FaIcon(FontAwesomeIcons.dollarSign,
                                  size: 20.0, color: jaune),
                              trailing: const Icon(Icons.view_list),
                              title: Text(
                                data.tarif.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsTarif(tarif: data, visible: visible)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      child: FloatingActionButton(
                      mouseCursor: MaterialStateMouseCursor.clickable,
                      child: const Icon(Icons.add),
                      splashColor: Colors.red,
                      hoverColor: Colors.red,
                      highlightElevation: 50,
                      elevation: 12,
                      tooltip: 'Ajouter tarif',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return const CreateTarif();
                        }));
                      },
                    ),
                    visible: visible,
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
