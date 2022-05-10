import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //Encoders and decoders for converting between different data
import '../../main.dart';
import '../../env.dart'; //to use the link to api in php
import '../../models/domaine.dart'; // to use class Domaine created
import '../domaines_screens/details.dart'; // to access to function to delete domaine
import '../domaines_screens/create.dart'; //to access to create Domaine
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListDomaine extends StatefulWidget {
  const ListDomaine({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<ListDomaine> {
  //late modifier can be used while declaring a non-nullable variable that's initialized after its declaration
  //use late variables if dont need to check whether they r initialized
  late Future<List<Domaine>> domaines;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final domaineListKey = GlobalKey<_ListState>();
  var visible = false;

  @override
  void initState() {
    super.initState();
    domaines = getDomaineList();
  }

  Future<String> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? '';
  }

  Future<List<Domaine>> getDomaineList() async {
    try {
      final String role = await getRole();
      setState(() {
        visible = role == 'admin' ? true : false;
      });
      final response =
          await http.get(Uri.parse('${Env.URL_PREFIX}/domaine/read_all.php'));
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        List<Domaine> domaines =
            items.map<Domaine>((json) => Domaine.fromJson(json)).toList();
        //another way to do by using List<E>.from() to down-cast a List (break down a parent json into children and make it iterable)
        //List<Domaine> domaines =
        // List<Domaine>.from(items.map((json) => Domaine.fromJson(json)));
        /**
         *  The purpose here is that you decode the response returned. The next step, is to turn that iterable of JSON objects into an instance of your object. This is done by creating fromJson methods in your class to properly take JSON and implement it accordingly
         */
        return domaines;
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
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
      key: domaineListKey,
      appBar: AppBar(
        title: const Text('Liste des domaines'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Domaine>>(
          future: domaines,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.data.isEmpty) {
              return AlertDialog(
                content: const Text("Il n'y a aucun domaine dans la liste"),
                actions: <Widget>[
                  Visibility(
                    child: ElevatedButton.icon(
                      label: const Text('Ajouter'),
                      icon: const Icon(Icons.playlist_add_outlined),
                      autofocus: true,
                      onPressed: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return const CreateDomaine();
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
              // Render domaine lists
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
                              leading: const FaIcon(FontAwesomeIcons.book,
                                  size: 20.0, color: jaune),
                              trailing: const Icon(Icons.view_list),
                              title: Text(
                                data.libelle.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailsDomaine(
                                          domaine: data, visible: visible)),
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
                        tooltip: 'Ajouter domaine',
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return const CreateDomaine();
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
