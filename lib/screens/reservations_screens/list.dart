import 'package:intl/intl.dart'; //for using DateFormat()
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //to use request http
import 'package:shared_preferences/shared_preferences.dart'; // for using SharedPreference
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
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final reservationListKey = GlobalKey<_ListState>();
  var visible = false;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getReservations();
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
  Future<void> getReservations() async {
    final String role = await getRole();
    setState(() {
      visible = role == 'admin' ? true : false;
    });
    if (role == "admin") {
      getReservationList();
    } else {
      final int idUser = await getIdUser();
      getReservationsById(idUser);
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

  Future<void> getReservationList() async {
    final response =
        await http.get(Uri.parse('${Env.URL_PREFIX}/reservation/read_all.php'));
    final items = json.decode(response.body);
    setState(() {
      _allReservations =
          items.map<Reservation>((json) => Reservation.fromJson(json)).toList();
    });
  }

  Future<void> getReservationsById(int id) async {
    final response = await http.post(
      Uri.parse('${Env.URL_PREFIX}/reservation/read_by_user.php'),
      body: jsonEncode({
        "idUser": id,
      }),
    );
    final items = json.decode(response.body);
    setState(() {
      _allReservations =
          items.map<Reservation>((json) => Reservation.fromJson(json)).toList();
    });
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
            Expanded(
              child: _searchResult.isNotEmpty ||
                      searchController.text.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _searchResult.length,
                      itemBuilder: (context, i) {
                        String dateDebut = DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.parse(_searchResult[i].debut));
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.bookmark,
                              color: jaune,
                              size: 30,
                            ),
                            trailing: const Icon(Icons.view_list),
                            title: Text(_searchResult[i].breveDes +
                                '  Debut: ' +
                                dateDebut),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailsReservation(
                                        reservation: _searchResult[i],
                                        visible: visible)),
                              );
                            },
                          ),
                          margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _allReservations.length,
                      itemBuilder: (context, index) {
                        String dateDebut = DateFormat('dd/MM/yyyy HH:mm')
                            .format(
                                DateTime.parse(_allReservations[index].debut));
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.bookmark,
                              color: jaune,
                              size: 30,
                            ),
                            trailing: const Icon(Icons.view_list),
                            title: Text(_allReservations[index].breveDes +
                                '  Debut: ' +
                                dateDebut),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailsReservation(
                                        reservation: _allReservations[index],
                                        visible: visible)),
                              );
                            },
                          ),
                          margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return CreateReservation(
                    visible: visible,
                  );
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
