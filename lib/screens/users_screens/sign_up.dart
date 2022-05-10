// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screens/users_screens/sign_in.dart';
import '../error.dart';
import 'package:test_app/screens/home.dart';
import '../../widgets/auth_api.dart';
import '../../models/user.dart';
import '../../main.dart';

// ignore: use_key_in_widget_constructors
class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // ignore: unused_field
  final AuthAPI _authAPI = AuthAPI();
  final formKey = GlobalKey<FormState>();
  late String email;
  late String mdpConfirm;
  late String mdp;
  bool displayPw = true;
  var iconShow = Icons.visibility;
  var iconHide = Icons.visibility_off;
  var icon = Icons.visibility;

  void navigate(String text) {
    switch (text) {
      case "L'inscription réussie!":
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));*/
        //another way to use routes in main.dart
        Navigator.pushNamed(context, '/home');
        break;
      case "L'email déjà existé!":
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignIn()));*/
        Navigator.pushNamed(context, '/signIn');
        break;
      case "Une erreur survenue!":
        /*Navigator.push(
            context, MaterialPageRoute(builder: (context) => Error()));*/
        Navigator.pushNamed(context, '/error');
        break;
      default:
        break;
    }
  }

  AlertDialog myAlert(String text) {
    return AlertDialog(
      content: Text(text),
      actions: <Widget>[
        ElevatedButton.icon(
          label: const Text('OK'),
          icon: const Icon(Icons.check),
          autofocus: true,
          onPressed: () => navigate(text),
        )
      ],
    );
  }

  void alert(BuildContext context, AlertDialog alertDialog) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void _onSignUp(context) async {
    String role = "user";
    String niveauTarif = "4";
    String droit = "0";
    final response =
        await _authAPI.signUp(email, mdp, role, niveauTarif, droit);
    if (response.statusCode == 200) {
      final res = await _authAPI.login(email, mdp);
      final item = json.decode(res.body);
      User user = User.fromJson(item);
      //set shared preferences to keep user logged in
      await _authAPI.userSaver(user.id, user.droitReservation, user.niveauTarif,
          user.role, user.email, user.jwt);

      var alertDialog = myAlert("L'inscription réussie!");
      alert(context, alertDialog);
      //send user to Home page with data of user included
    } else if (response.statusCode == 400) {
     
      var alertDialog = myAlert("L'email déjà existé!");
      alert(context, alertDialog);
      //if email already existe!
    } else {
      
      var alertDialog = myAlert("Une erreur survenue!");
      alert(context, alertDialog);
      //error server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: jaune,
        title: const Text(
          "Maison des ligues",
          style: TextStyle(color: rouge),
        ),
        elevation: 16.0,
        leading: Image.asset('assets/images/M2L net rond.png', height: 25.0),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.house, color: bleu,),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
          child: Column(
            children: [
              SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/M2L net rond.png')),
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    const Text(
                      "S'inscrire",
                      style: TextStyle(
                          color: bleu,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                        width: 400,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ doit être rempli';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(hintText: "E-mail"),
                          onChanged: (val) => setState(() => email = val),
                        )),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ doit être rempli';
                          }
                          return null;
                        },
                        obscureText: displayPw,
                        decoration: InputDecoration(
                          hintText: "Mot de passe",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                displayPw = !displayPw;
                                displayPw ? icon = iconShow : icon = iconHide;
                              });
                            },
                            icon: Icon(icon),
                          ),
                        ),
                        onChanged: (val) => setState(() => mdp = val),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ce champ doit être rempli';
                          } else if (value != mdp) {
                            return 'Mot de passe doit être pareil';
                          }
                          return null;
                        },
                        obscureText: displayPw,
                        decoration: InputDecoration(
                          hintText: "Confirmer mot de passe",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                displayPw = !displayPw;
                                displayPw ? icon = iconShow : icon = iconHide;
                              });
                            },
                            icon: Icon(icon),
                          ),
                        ),
                        onChanged: (val) => setState(() => mdpConfirm = val),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: jaune,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.all(10)),
                        child: const Text("S'INSCRIRE"),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _onSignUp(context);
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
