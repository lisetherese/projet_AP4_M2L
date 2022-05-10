// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:test_app/screens/reservations_screens/create.dart';
import 'package:test_app/screens/users_screens/sign_in.dart';
import 'package:test_app/screens/users_screens/sign_up.dart';
import 'dart:convert'; //Encoders and decoders for converting between different data
import '../main.dart';
import '../env.dart'; //to use the link to api in php
import '../models/reservation.dart';
//import '../models/salle.dart'; // to use class Salle created
//import 'reservations_screens/details.dart';
//import 'salles_screens/details.dart'; // to access to function to delete salle
//import 'salles_screens/create.dart'; //to access to create Salle
import 'tarifs_screens/list.dart';
import 'domaines_screens/list.dart';
import 'salles_screens/list.dart';
import 'reservations_screens/list.dart';

//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}


List<Reservation> _searchResult = [];
List<Reservation> _allReservations = [];
class HomeState extends State<Home> {
  //late modifier can be used while declaring a non-nullable variable that's initialized after its declaration
  late Future<List<Reservation>> reservations;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final reservationListKey = GlobalKey<HomeState>();
  //set visibility to certain widgets selon role = 'admin' or not
  bool visible = false;
  late String email;
  late String role;
  bool isLoggedIn = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    reservations = getReservationList();
    super.initState();
  }

  Future<List<Reservation>> getReservationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";
    role = prefs.getString('role') ?? '';
    isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    setState(() {
      visible = role == 'admin' ? true : false;
    });
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();

    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var reservation in _allReservations) {
      if (reservation.breveDes.contains(text) ||
          reservation.des.contains(text) ||
          reservation.debut.contains(text) ||
          reservation.fin.contains(text)) {
        _searchResult.add(reservation);
      }
    }
    setState(() {});
  }

  void _onLogOut(context) async {
    //clear all shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // clear routes
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/splash', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: (isLoggedIn)
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    padding: const EdgeInsets.only(top: 40.0, left: 20.0),
                    child: Text(
                      "Menu pour ${email} \n Role: ${role}",
                      style:
                          const TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                    decoration: const BoxDecoration(
                      color: jaune,
                    ),
                  ),
                  ListTile(
                      leading: const Icon(
                        Icons.bungalow,
                        color: jaune,
                        size: 20,
                      ),
                      title: const Text('Liste des salles'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ListSalle();
                        }));
                      }),
                  ListTile(
                      leading: const FaIcon(FontAwesomeIcons.euroSign,
                          size: 20.0, color: jaune),
                      title: const Text('Liste des tarifs'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ListTarif();
                        }));
                      }),
                  ListTile(
                      leading: const FaIcon(FontAwesomeIcons.servicestack,
                          size: 20.0, color: jaune),
                      title: const Text('Liste des domaines'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ListDomaine();
                        }));
                      }),
                  ListTile(
                      leading: const Icon(
                        Icons.bookmark,
                        color: jaune,
                        size: 20,
                      ),
                      title: const Text('Liste des reservations'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ListReservation();
                        }));
                      }),
                  ListTile(
                      leading: const Icon(
                        Icons.change_circle,
                        color: jaune,
                        size: 20,
                      ),
                      title: const Text('Changer mot de passe'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SignUp();
                        }));
                      }),
                  ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: jaune,
                        size: 20,
                      ),
                      title: const Text('Se déconnecter'),
                      onTap: () {
                        _onLogOut(context);
                      }),
                ],
              ),
            )
          : null,
      key: reservationListKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // here the desired height
        child: AppBar(
          centerTitle: true,
          //leading: Image.asset('assets/images/M2L net rond.png', height: 25.0),
          title: (isLoggedIn)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/M2L net rond.png', height: 40.0),
                    const Text(
                      'Maison des Ligues',
                      style: TextStyle(color: rouge, fontSize: 16),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/M2L net rond.png', height: 70.0),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      'Maison des Ligues',
                      style: TextStyle(color: rouge, fontSize: 25),
                    ),
                  ],
                ),
          actions: <Widget>[
            (isLoggedIn)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                        icon: const Icon(
                          Icons.account_circle_rounded,
                          color: bleu,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                      )),
                      Text(
                        role,
                        style: const TextStyle(color: bgColor, fontSize: 15),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.login,
                      color: rouge,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signIn');
                    },
                  )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             Padding(
              padding: const EdgeInsets.fromLTRB(3, 14, 3, 4),
              child: Card(
                color: searchColor,
                child: ListTile(
                  leading: const Icon(Icons.search),
                  title: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                        hintText: 'Recherche par description ou date heure',
                        border: InputBorder.none),
                    onChanged: onSearchTextChanged,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      searchController.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
             /* Expanded(
                child: FutureBuilder<List<Reservation>>(
                future: reservations,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  // By default, show a loading spinner.
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return AlertDialog(
                      content: const Text(
                          "Il n'y a aucune reservation dans la liste"),
                      actions: <Widget>[
                        Visibility(
                          child: ElevatedButton.icon(
                            label: const Text('Ajouter'),
                            icon: const Icon(Icons.playlist_add_outlined),
                            autofocus: true,
                            onPressed: () => {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return const CreateReservation();
                              }))
                            },
                          ),
                          //by default de visible will set to false and the replaced part showed first
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
                              itemCount: snapshot.data == null
                                  ? 0
                                  : snapshot.data.length,
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
                                      data.breveDes,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsReservation(
                                                  reservation: data,
                                                  visible: visible,
                                                )),
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
                              tooltip: 'Ajouter reservation',
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return const CreateReservation();
                                }));
                              },
                            ),
                            visible: visible,
                          ),
                        ]);
                  }*/
                  //return const CircularProgressIndicator();
                //},
             // ),
              //),
            ],
          ),
        ),
      ),
    );
  }
}
