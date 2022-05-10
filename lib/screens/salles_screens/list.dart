import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //Encoders and decoders for converting between different data

import '../../env.dart'; //to use the link to api in php
import '../../models/salle.dart'; // to use class Salle created
import '../salles_screens/details.dart'; // to access to function to delete salle
import '../salles_screens/create.dart'; //to access to create Salle
import '../../main.dart';

class ListSalle extends StatefulWidget {
  const ListSalle({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
}


class _ListState extends State<ListSalle> {
  //late modifier can be used while declaring a non-nullable variable that's initialized after its declaration
  late Future<List<Salle>> salles;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final salleListKey = GlobalKey<_ListState>();
  var visible = false;

  
  @override
  void initState() {
    super.initState();
    salles = getSalleList();
   
  }

  Future<String> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? '';
  }

  Future<List<Salle>> getSalleList() async {
    try {
      final String role = await getRole();
      setState(() {
        visible = role == 'admin' ? true : false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      key: salleListKey,
      appBar: AppBar(
        title: const Text('Liste des salles'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Salle>>(
          future: salles,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return AlertDialog(
                content: const Text("Il n'y a aucun salle dans la liste"),
                actions: <Widget>[
                  Visibility(
                    child:
                  ElevatedButton.icon(
                    label: const Text('Ajouter'),
                    icon: const Icon(Icons.playlist_add_outlined),
                    autofocus: true,
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return const CreateSalle();
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
              // Render salle lists
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
                                Icons.bungalow,
                                color: jaune,
                                size: 30,
                              ),
                              trailing: const Icon(Icons.view_list),
                              title: Text(
                                data.nom,
                                style: const TextStyle(fontSize: 20),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailsSalle(salle: data, visible: visible)),
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
                      tooltip: 'Ajouter salle',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return const CreateSalle();
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
